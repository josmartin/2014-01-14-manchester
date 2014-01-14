function TrainingEvaluation(in)

% TrainingEvaluation - creates a GUI to guide the user through the
% Evaluation registration process.
%
%   TrainingEvaluation OfficeCode
%   TrainingEvaluation(OfficeCode)
%
%   If the string OfficeCode matches one of the supported office codes, then
%   the GUI will skip the language selection page and open up on the
%   second page with the relevant office chosen.
%
%	Valid Office codes: Natick, AU, CN, FR, DE, IN, IT, JP, BNL, Pan-Euro, KR, ES, SE, CH, UK
%
%   TrainingEvaluation LanguageCode
%   TrainingEvaluation(LanguageCode)
%
%   If provided and matches one of the supported languages, then skip the
%   first section and move on to the second window. NB OfficeCode has
%   higher priority than LanguageCode
%
%	Valid language codes: EN, JA, KO, ZH
% 
%   When entering the year, the range displayed is the current year
%   (according to the computer clock) and the previous 5 years. If this 
%   does not contain the necessary year, then double click on the Year Edit
%   box and you can enter the relevant year.
%


%% Set up place holders for data
% First Data that the GUI needs
Languages = []; % Supported Languages
Offices = []; % MathWorks Offices
Types = [];
Months = [];
% Cell array containing questions translated into the supported languages
Prompts = {};
handles = []; % Structure to store handles to object in GUI

%% Set up the default choices:
LangCode = 'EN'; % English
OfficeIndex = 1; % Australia
Course = []; % Public course as default

% Call a function to create this data.
load TE_i18n_data


%% Use current date as produced by the computer, users can change this if
% they wish
Date = clock;
Date = Date(1:3);
Email = ''; % Users Email address
Office = ''; % Office running course
Course = ''; % Public or On-site
CourseType = 1; % Public or onsite (by number)
CurrentPage = 1;  % Page being shown
BackEnable = 'off'; % Status of back button

if nargin > 0
    nInitialise(in);
end

%% Now build the GUI
fwdh = 450; % Figure Width
fhgt = 300; % Figure Height

nCreate;
nSetPage;
nSetStrings;

% Added by Eric.
useLangLocale

set(handles.Figure,'visible','on');

%% ------------------------------------------------------------------------
    function nCreate
        % Nested function to create the GUI

        % First get current screen size so that we can put GUI in centre of
        % the screen
        sUnits = get(0,'Units'); % most likely this will be pixels
        set(0,'Units','pixels'); % Set units to pixels
        S = get(0,'screensize'); % Grab screensize
        set(0,'Units',sUnits);   % reset screen units
        % Reset default fontsize to 10
        CrtSz = get(0,'DefaultUIcontrolFontSize');
        set(0,'DefaultUIcontrolFontSize',10);

        % Now create the figure - make its colour the same as the default
        % background for uicontrols so that text boxes blend in with the
        % background

        handles.Figure = figure(...
            'numbertitle','off',...
            'handlevisibility','off',...
            'menubar','none',...
            'color',get(0,'DefaultUicontrolBackgroundColor'),...
            'position',[(S(3)-fwdh)/2 (S(4)-fhgt)/2-100 fwdh fhgt],...
            'visible','off',...
            'resize','off',...
            'tag',mfilename);

        % Create a separator to partition the GUI
        % Call an ugly hack due to the way uibuttongroups have changed
        % between 2006b and 2007a

        [v,d] = version;
        d = datenum(d);
        if d < 733071
            % R2006b or before
            set(handles.Figure,'HandleVisibility','on');
            handles.Separator = uibuttongroup;
            handles.Display = uibuttongroup;
            set(handles.Figure,'HandleVisibility','off');
        else
            % r2007a or later
            handles.Separator = uibuttongroup(handles.Figure);
            handles.Display = uibuttongroup(handles.Figure);
        end

        set(handles.Separator,...
            'units','pixels',...
            'bordertype','etchedin',...
            'position',[20 40 fwdh-40 2]);

        callbacks = {@nBack, @nNext, @nContinue};
        Names = {'Back','Next','Continue'};
        enable = {BackEnable,'on','off'};

        for i = 1:numel(Names)
            handles.(Names{i}) = uicontrol(handles.Figure,...
                'callback',callbacks{i},...
                'enable',enable{i});
        end

        % Create the controls for the first page
        handles.LanguageText = uicontrol(handles.Figure,...
            'position',[50 fhgt*.6+25 fwdh-100 20],...
            'horizontalalignment','left',...
            'style','text');

        handles.LanguagePopup = uicontrol(handles.Figure,...
            'string',Languages.List,...
            'style','popup',...
            'backgroundcolor',[1 1 1],...
            'position',[100 fhgt*.6 fwdh-200 20],...
            'callback',@nLanguage);

        % Create the controls for the second page
        % Email boxes go on top third
        ehgt = (fhgt-80)*1/2+60;

        handles.EmailText = uicontrol(handles.Figure,...
            'position',[50 ehgt+80 fwdh-100 20],...
            'horizontalalignment','left',...
            'style','text');

        handles.EmailBox = uicontrol(handles.Figure,...
            'string','',...
            'position',[50 ehgt+55 fwdh-100 20],...
            'horizontalalignment','left',...
            'style','edit',...
            'backgroundcolor',[1 1 1],...
            'callback',@nEmail);
        
        handles.ReEmailText = uicontrol(handles.Figure,...
            'position',[50 ehgt+25 fwdh-100 20],...
            'horizontalalignment','left',...
            'style','text');

        handles.ReEmailBox = uicontrol(handles.Figure,...
            'string','',...
            'position',[50 ehgt fwdh-100 20],...
            'horizontalalignment','left',...
            'style','edit',...
            'backgroundcolor',[1 1 1]);

        % Office boxes go in the middle third
        ohgt = (fhgt-80)*1/4+60;
        handles.OfficeText = uicontrol(handles.Figure,...
            'position',[50 ohgt+25 fwdh-100 20],...
            'horizontalalignment','left',...
            'style','text');

        handles.OfficePopup = uicontrol(handles.Figure,...
            'position',[50 ohgt fwdh-100 20],...
            'horizontalalignment','left',...
            'style','popup',...
            'backgroundcolor',[1 1 1],...
            'callback',@nOffice);
        
        % Course type and date controls in bottom third
        
        handles.DateText = uicontrol(handles.Figure,...
            'position',[fwdh-230 85 100 20],...
            'style','text',...
            'horizontalalignment','left');

        DayString = num2str((1:31)');

        handles.DayPopup = uicontrol(handles.Figure,...
            'string',DayString,...
            'position',[fwdh-230 60 40 20],...
            'value',Date(3),...
            'style','popup',...
            'backgroundcolor',[1 1 1],...
            'callback',@nDate);

        handles.MonthPopup = uicontrol(handles.Figure,...
            'position',[fwdh-185 60 80 20],...
            'style','popup',...
            'value',Date(2),...
            'backgroundcolor',[1 1 1],...
            'callback',@nDate);

        handles.YearBox = uicontrol(handles.Figure,...
            'position',[fwdh-100 60 40 20],...
            'style','edit',...
            'string',num2str(Date(1)),...
            'enable','inactive',...
            'backgroundcolor',[1 1 1],...
            'buttondownfcn',@nButtonDown,...
            'callback',@nDate);

        handles.YearSlider = uicontrol(handles.Figure,...
            'position',[fwdh-60 60 10 20],...
            'style','slider',...
            'max',Date(1),...
            'min',Date(1)-5,...
            'value',Date(1),...
            'sliderstep',[.2,.2],...
            'backgroundcolor',[1 1 1],...
            'callback',@nSlider);

        handles.TypeText = uicontrol(handles.Figure,...
            'position',[50 85 80 20],...
            'style','text',...
            'horizontalalignment','left');

        handles.TypePopup = uicontrol(handles.Figure,...
            'position',[50 60 80 20],...
            'value',CourseType,...
            'style','popup',...
            'backgroundcolor',[1 1 1],...
            'callback',@nType);

        axpos = [20 60 fwdh-40 fhgt-80];

        set(handles.Display,...
            'units','pixels',...
            'bordertype','etchedin',...
            'position',axpos,...
            'backgroundcolor',[1 1 1]);

        handles.ReviewText = uicontrol('parent',handles.Figure,...
            'style','text',...
            'position',axpos+[10 10 -20 -20],...
            'fontweight','bold',...
            'backgroundcolor',[1 1 1],...
            'horizontalalignment','left');

        % Log the relevant handles to the page they belong to
        handles.Page{1} = [handles.LanguageText;...
            handles.LanguagePopup];

        handles.Page{2} = [handles.EmailText;...
            handles.EmailBox;...
            handles.OfficeText;...
            handles.OfficePopup;...
            handles.DateText;...
            handles.DayPopup;...
            handles.MonthPopup;...
            handles.TypeText;...
            handles.TypePopup;...
            handles.YearSlider;...
            handles.YearBox;...
            handles.ReEmailText;...
            handles.ReEmailBox];

        handles.Page{3} = [handles.Display;...
            handles.ReviewText];
        
        

        % Reset font
        set(0,'DefaultUIControlFontSize',CrtSz);

    end
%% ------------------------------------------------------------------------
    function nPosition

        % Decide on the positions of the controls depending on the extent
        % of the text inside them.

        % First run through the controls and resize them if their extent is
        % larger than the control

        % All the controls we create should have height 20 pixels. At
        % standard text size, vertical extent should be 17
        CtrlH = 20;

        Controls = [handles.Page{1}(:); handles.Page{2}(:)];
        for ii = 1:length(Controls)
            pos = get(Controls(ii),'position');
            ext = get(Controls(ii),'extent');
            if ext(3) > pos(3)
                pos(3) = 5*ceil(ext(3)/5);
            end
            if ext(4) > pos(4)
                pos(4) = 5*ceil(ext(4)/5);
            end
            set(Controls(ii),'position',[pos(1) pos(2) pos(3) pos(4)]);
        end
        
        % Make sure the slider is in line with the year box
        pos = get(handles.YearSlider,'position');
        pos1 = get(handles.YearBox,'position');
        set(handles.YearSlider,'position',[pos(1:3) pos1(4)]);
        
        % Now look at the "Back" "Next" and "Continue" buttons. Get their
        % extents and then make sure they have the same sizes and then
        % place them across the base of the GUI
        Names = {'Back','Next','Continue'};
        N = numel(Names);
        W = zeros(N,1);
        for ii = 1:N
            pos = get(handles.(Names{ii}),'extent');
            W(ii) = pos(3);
        end
        BtnW = max(max(W),60);
        gap = (fwdh-N*BtnW)/(N+1);
        for ii = 1:N
            set(handles.(Names{ii}),'position',...
                [ii*gap+(ii-1)*BtnW 10 BtnW CtrlH]);
        end

    end
%% ------------------------------------------------------------------------
    function nSetStrings

        % In this function we set the strings according to the language
        % that has been selected

        % Now set the strings for all the controls
        Controls = {'Back','Next','Continue','LanguageText',...
            'EmailText','OfficeText','DateText','TypeText',...
            'ReEmailText'};
        
        cIdx = strmatch(LangCode,Prompts.LanguageCodes);

        for ii = 1:length(Controls)
            set(handles.(Controls{ii}),'string',Prompts.(Controls{ii}){cIdx});
        end
        set(handles.Figure,'name',Prompts.Figure{cIdx});

        % Now populate the office drop down
        cIdx = strmatch(LangCode,Offices.LanguageCodes);
        set(handles.OfficePopup,'string',Offices.List{cIdx},...
            'value',OfficeIndex);

        % Now populate the Month drop down
        cIdx = strmatch(LangCode,Months.LanguageCodes);
        set(handles.MonthPopup,'string',Months.List{cIdx});

        % Now populate Course types drop down
        cIdx = strmatch(LangCode,Types.LanguageCodes);
        set(handles.TypePopup,'string',Types.List{cIdx});

        % Different languages may cause problems with the sizes of the
        % controls as the strings may be too long for the boxes provided.
        % Call the positioning function
        nPosition;

    end
%% ------------------------------------------------------------------------
    function emailCode = nCheckEmails
         
        % Check that the user has entered something in the two email boxes
        % and that what has been entered matches
        emailCode = 0; % Assume all will be well.
        
        ReEmail = get(handles.ReEmailBox,'string'); 
        % We don't need to get the string from the first box since this is
        % automatically recorded by the callback from that control
        if isempty(Email) || isempty(ReEmail)
            emailCode = 1;
        elseif ~strcmp(Email,ReEmail)
            emailCode = 2;
        end
        
    end

%% ------------------------------------------------------------------------
    function nBack(src,evt) %#ok

        CurrentPage = CurrentPage-1;
        if CurrentPage == 1
            set(handles.Back,'enable','off');
        end
        set(handles.Continue,'enable','off');
        set(handles.Next,'enable','on');
        nSetPage;

    end

%% ------------------------------------------------------------------------
    function nNext(src,evt) %#ok

        % First check to see if they have entered a valid email
        if CurrentPage == 2 
            emailCode = nCheckEmails;
            switch emailCode
                case 0
                    % All OK, do nothing
                case 1
                    % an email is empty
                    LangIdx = strmatch(LangCode,Prompts.LanguageCodes);
                    msgbox(Prompts.MsgBoxMsg{LangIdx},...
                        Prompts.MsgBoxTitle{LangIdx},'modal');
                    return
                case 2
                    % The emails do not match
                    LangIdx = strmatch(LangCode,Prompts.LanguageCodes);
                    msgbox(Prompts.MisMatchMsg{LangIdx},...
                        Prompts.MisMatchTitle{LangIdx},'modal');
                    return
            end
        end

        CurrentPage = CurrentPage+1;
        if CurrentPage == numel(handles.Page)
            set(handles.Next,'enable','off');
            set(handles.Continue,'enable','on');
        end
        set(handles.Back,'enable','on');
        nSetPage;
        nUpdateReview;

    end

%% ------------------------------------------------------------------------
    function nContinue(src,evt) %#ok

        str = ['Email: ',Email,char(10),...
            'Office: ',Offices.Codes{OfficeIndex},char(10),...
            'Language: ',LangCode,char(10),...
            'Date: ',datestr([Date 0 0 0]),char(10),...
            'Course Type: ',Types.List{1}{CourseType}];

        %disp(str);
        
        %function urlpost(surveyID, language, office, endDate, emailAddress)
        url = 'http://www.customersat3.com/csc/mw/WquiEqiP.asp';
 
        % Check if course is On-Site or Public
        if CourseType == 2
            SurveyID = '6085'; % On-Site
        else
            SurveyID= '6084'; % Public
        end
        Language = LangCode;
        TrainingOffice = Offices.Codes{OfficeIndex};
        EndDate = datestr([Date 0 0 0],'yyyy-mm-dd');
        EmailAddress = Email; 

        % Create a web page to automatically submit the form
        filename = [tempname '.html'];
        fid = fopen(filename, 'wt');
        if (fid < 0)
            error(['Unable to write temporary Internet file: ' filename]);
        end
    
       % Standard header
       fprintf(fid, '<html><head><title>Accessing Evaluation</title></head>\n');
       fprintf(fid, '<body onload="form1.submit()"><p>Accessing Evaluation...\n');
    
        % Form Content
        fprintf(fid, '<form name="form1" method="post" action="%s">\n', url);
        fprintf(fid, '<input type="hidden" name="SurveyID" value="%s">\n', SurveyID);
        fprintf(fid, '<input type="hidden" name="Language" value="%s">\n', Language);
        fprintf(fid, '<input type="hidden" name="TrainingOffice" value="%s">\n', TrainingOffice);
        fprintf(fid, '<input type="hidden" name="EndDate" value="%s">\n', EndDate);
        fprintf(fid, '<input type="hidden" name="EmailAddress" value="%s">\n', EmailAddress);

        % Standard footer
        fprintf(fid, '</form></body></html>\n');
       
        fclose(fid);

        % Open the page in a web browser
        winopen(filename);
        
        % Close GUI
        delete(handles.Figure)
        
%         %function urlpost(surveyID, language, office, endDate, emailAddress)
%         url = 'http://www.customersat3.com/csc/mw/WquiEqiP.asp';
% 
%         params = {...
%             'SurveyID', '6084',...
%             'Language', LangCode, ...
%             'TrainingOffice', Offices.Codes{OfficeIndex},...
%             'EndDate', datestr([Date 0 0 0],'yyyy-mm-dd'), ...
%             'EmailAddress', Email};
% 
%         % Check if training is On-Site 
%         if CourseType == 2  
%             params.SurveyID = '6085';
%         end
% 
%         % Create a post request to the web server
%         [content, code] = urlread(url, 'post', params);
%     
%         % Perform a quick check on the status code
%         if (code ~= 1 || isempty(content))
%             error('Unable to contact the Web server, or incorrect input parameters.');
%         end
%         % Since the user needs to view this web page, write it to a file
%         filename = [tempname '.html'];
%         fid = fopen(filename, 'wt');
%         if (fid < 0)
%             error(['Unable to write temporary Internet file: ' filename]);
%         end
% 
%         fprintf(fid, '%c', content);
%         fclose(fid);
%   
%         % Open the page in a web browser
%         %web(['file://' filename]);
%         winopen(filename);
    end

%% ------------------------------------------------------------------------
    function nSetPage

        for ii = 1:length(handles.Page)
            if ii == CurrentPage
                set(handles.Page{ii},'visible','on');
            else
                set(handles.Page{ii},'visible','off');
            end
        end

    end

%% ------------------------------------------------------------------------
    function nLanguage(src,evt) %#ok

        LangCode = Languages.Codes{get(handles.LanguagePopup,'value')};
        nSetStrings;

    end

%% ------------------------------------------------------------------------
    function nEmail(src,evt) %#ok

        Email = get(handles.EmailBox,'string');
        nUpdateReview;

    end

%% ------------------------------------------------------------------------
    function nOffice(src,evt) %#ok

        OfficeIndex = get(handles.OfficePopup,'value');
        nUpdateReview;

    end

%% ------------------------------------------------------------------------
    function nType(src,evt) %#ok

        CourseType = get(handles.TypePopup,'value');
        nUpdateReview;
    end
%% ------------------------------------------------------------------------
    function nDate(src,evt) %#ok

        Date(3) = get(handles.DayPopup,'value');
        Date(2) = get(handles.MonthPopup,'value');
        Yr = str2double(get(handles.YearBox,'string'));
        if isempty(Yr)
            set(handles.YearBox,'string',num2str(Date(1)));
        else
            Date(1) = Yr;
            mn = get(handles.YearSlider,'min');
            mx = get(handles.YearSlider,'max');
            if Yr < mn
                set(handles.YearSlider,'min',Yr,...
                    'sliderstep',1/(mx-Yr)*[1 1],'value',Yr);
            elseif Yr > mx
                set(handles.YearSlider,'max',Yr,...
                    'sliderstep',1/(Yr-mn)*[1 1],'value',Yr);
            end
        end

        nUpdateReview;

    end
%% ------------------------------------------------------------------------
    function nSlider(src,evt) %#ok

        val = get(handles.YearSlider,'value');
        Date(1) = val;
        set(handles.YearBox,'string',num2str(Date(1)));
        nDate;

    end
%% ------------------------------------------------------------------------
    function nButtonDown(src,evt) %#ok

        stype = get(handles.Figure,'SelectionType');
        if strcmp(stype,'open')
            set(handles.YearBox,'enable','on');
        end

    end
%% ------------------------------------------------------------------------
    function nUpdateReview

        cIdx = strmatch(LangCode,Offices.LanguageCodes);
        Office = Offices.List{cIdx}{OfficeIndex};
        cIdx = strmatch(LangCode,Types.LanguageCodes);
        Course = Types.List{cIdx}{CourseType};

        if strcmp(Office,Offices.List{2}{1})
            DateString = datestr([Date 0 0 0],'mm/dd/yyyy');
        else
            DateString = datestr([Date 0 0 0],'dd/mm/yyyy');
        end

        cIdx = strmatch(LangCode,Prompts.LanguageCodes);
        str = [Prompts.Review{cIdx},char(10),char(10),...
            Prompts.ReviewEmail{cIdx},Email,char(10),...
            Prompts.ReviewOffice{cIdx},Office,char(10),...
            Prompts.TypeText{cIdx},Course,char(10),...
            Prompts.DateText{cIdx},DateString];

        set(handles.ReviewText,'string',str);

    end
%% ------------------------------------------------------------------------
    function nInitialise(in)

        % Parse in - it can be either a ry code or a language code, if
        % it is valid then skip page 1 and set up page 2 accordingly


        Index = strmatch(lower(in),lower(Offices.Codes));
        if ~isempty(Index)
            LangCode = Offices.Language{Index};
            OfficeIndex = Index;
            CurrentPage = 2;
            BackEnable = 'on';
        else
            Index = strmatch(lower(in),lower(Languages.Codes));
            if ~isempty(Index)
                LangCode = Languages.Codes{Index};
                % Set the office index to be the first office with that
                % language
                OfficeIndex = strmatch(LangCode,Offices.Language);
                OfficeIndex = OfficeIndex(1);
                CurrentPage = 2;
                BackEnable = 'on';
            end
        end

    end
%% ------------------------------------------------------------------------
    function nSetupData


        
    end
%% ------------------------------------------------------------------------
    function useLangLocale
        % Created by Eric.
        % Retrive OS language setting and use it as default.
        local_lc = get(0, 'Language');
        idx = find(strcmpi(local_lc(1:2), Languages.Codes));
        if isempty(idx)
            idx = 1;
        end
        set(handles.LanguagePopup,'value',idx);
        nLanguage();
    end

end
