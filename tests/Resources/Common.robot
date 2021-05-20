*** Settings ***
Library   JupyterLibrary
Resource  Page/ODH/JupyterHub/JupyterLabLauncher.robot

*** Keywords ***
Begin Web Test
    Open Browser  ${ODH_DASHBOARD_URL}  browser=${BROWSER.NAME}  options=${BROWSER.OPTIONS}

End Web Test
    ${server} =  Run Keyword and Return Status  Page Should Contain Element  //div[@id='jp-top-panel']//div[contains(@class, 'p-MenuBar-itemLabel')][text() = 'File']
    IF  ${server}
        Clean Up Server
        Click JupyterLab Menu  File
        Capture Page Screenshot
        Click JupyterLab Menu Item  Hub Control Panel
        Switch Window  JupyterHub
        Sleep  5
        Click Element  //*[@id="stop"]
        Wait Until Page Contains  Start My Server  timeout=15
        Capture Page Screenshot
    END
    Close Browser