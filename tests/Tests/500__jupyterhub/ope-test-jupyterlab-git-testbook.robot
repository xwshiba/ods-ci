*** Settings ***
Resource         ../../Resources/ODS.robot
Resource         ../../Resources/Common.robot
Resource         ../../Resources/Page/ODH/JupyterHub/JupyterHubSpawner.robot
Resource         ../../Resources/Page/ODH/JupyterHub/JupyterLabLauncher.robot
Library          DebugLibrary
Suite Setup      Begin Web Test
Suite Teardown   End Web Test
Force Tags       JupyterHub

*** Variables ***
${ope_image}            byon-1669072197263
${TEST_BOOK_PATH}=     ope/content/
@{TEST_BOOK_CHAPTER} =    01_special_displays    03_animations_examples
@{TEST_BOOK_PAGE} =    special_displays.ipynb    animations.ipynb

*** Test Cases ***
Open RHODS Dashboard
  [Tags]  Sanity
  Wait for RHODS Dashboard to Load

Can Launch Jupyterhub
  [Tags]  Sanity
  Launch Jupyter From RHODS Dashboard Link

Can Login to Jupyterhub
  [Tags]  Sanity
  Login To Jupyterhub  ${TEST_USER.USERNAME}  ${TEST_USER.PASSWORD}  ${TEST_USER.AUTH_TYPE}
  ${authorization_required} =  Is Service Account Authorization Required
  Run Keyword If  ${authorization_required}  Authorize jupyterhub service account
  #Wait Until Page Contains Element  xpath://span[@id='jupyterhub-logo']
  Wait Until Page Contains  Start a notebook server

Can Spawn Notebook
  [Tags]  Sanity
  Fix Spawner Status
  Spawn Notebook With Arguments  image=${ope_image}

Can Launch Open Education Test Notebook
  [Tags]  Sanity
  ##################################################
  # Manual Notebook Input
  ##################################################
  Sleep  5
  Add and Run JupyterLab Code Cell in Active Notebook  !pip install boto3
  Wait Until JupyterLab Code Cell Is Not Active
  #Get the text of the last output cell
  ${output} =  Get Text  (//div[contains(@class,"jp-OutputArea-output")])[last()]
  Should Not Match  ${output}  ERROR*

  Add and Run JupyterLab Code Cell in Active Notebook  import os
  Add and Run JupyterLab Code Cell in Active Notebook  print("Hello World!")
  Capture Page Screenshot

  JupyterLab Code Cell Error Output Should Not Be Visible

  ##################################################
  # Git clone repo and run test book
  ##################################################
  Navigate Home (Root folder) In JupyterLab Sidebar File Browser
  Open With JupyterLab Menu  Git  Clone a Repository
  Input Text  //div[.="Clone a repo"]/../div[contains(@class, "jp-Dialog-body")]//input  https://github.com/xwshiba/ope.git
  Click Element  xpath://div[.="Clone"]

  Open With JupyterLab Menu  File  Open from Path…
  Input Text  //div[.="Open Path"]/../div[contains(@class, "jp-Dialog-body")]//input  ope/
  Click Element  xpath://div[.="Open"]

  Sleep  1

  Capture Page Screenshot

  Maybe Open JupyterLab Sidebar   Git
  Click Element  xpath://*[@id="jp-git-sessions"]/div/div[1]/div[3]/button
  Click Element  xpath://span[text()='origin/test-book']

  Sleep  5

  ${cnt}=    Get length    ${TEST_BOOK_CHAPTER}
  FOR    ${counter}    IN RANGE    ${cnt}
      Run Test Book Chapter And Verify No Error    ${TEST_BOOK_PATH}/${TEST_BOOK_CHAPTER}[${counter}]/${TEST_BOOK_PAGE}[${counter}]    ${TEST_BOOK_PAGE}[${counter}]
  END

*** Keywords ***
Run Test Book Chapter And Verify No Error
    [Documentation]    Runs a test book chapter and verify there is no output error
    [Arguments]    ${test_book_chapter}    ${test_book_page}
    Open With JupyterLab Menu  File  Open from Path…
    Input Text  //div[.="Open Path"]/../div[contains(@class, "jp-Dialog-body")]//input  ${test_book_chapter}
    Click Element  xpath://div[.="Open"]

    Wait Until ${test_book_page} JupyterLab Tab Is Selected
    Close Other JupyterLab Tabs

    Open With JupyterLab Menu  Run  Run All Cells
    Wait Until JupyterLab Code Cell Is Not Active
    JupyterLab Code Cell Error Output Should Not Be Visible

    #Get the text of the last output cell
    ${output} =  Get Text  (//div[contains(@class,"jp-OutputArea-output")])[last()]
    Should Not Match  ${output}  ERROR*
