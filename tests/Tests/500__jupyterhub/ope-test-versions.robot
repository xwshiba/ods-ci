*** Settings ***
Documentation       Test Suite to verify installed library versions

Resource            ../../Resources/ODS.robot
Resource            ../../Resources/Common.robot
Resource            ../../Resources/Page/ODH/JupyterHub/JupyterHubSpawner.robot
Resource            ../../Resources/Page/ODH/JupyterHub/JupyterLabLauncher.robot
Resource            ../../Resources/Page/OCPDashboard/Builds/Builds.robot
Library             JupyterLibrary

Suite Setup         Load Spawner Page
Suite Teardown      End Web Test

Force Tags          JupyterHub


*** Variables ***
@{status_list}      # robocop: disable
&{package_versions}      # robocop: disable
${ope_image}            byon-1669072197263
${JupyterLab_Version}         v3.4
${Notebook_Version}           v6.4


*** Test Cases ***
Open JupyterHub Spawner Page
    [Documentation]    Verifies that Spawner page can be loaded
    [Tags]    Sanity
    ...       ODS-695
    Pass Execution    Passing tests, as suite setup ensures that spawner can be loaded

Verify Libraries in Open Education Image
    [Documentation]    Verifies libraries in PyTorch image
    [Tags]    Sanity
    ...       ProductBug
    Verify List Of Libraries In Image    ${ope_image}

Verify All Images And Spawner
    [Documentation]    Verifies that all images have the correct libraries with same versions
    [Tags]    Sanity
    ...       ProductBug
    List Should Not Contain Value    ${status_list}    FAIL
    ${length} =    Get Length    ${status_list}
    Should Be Equal As Integers    ${length}    1
    Log To Console    ${status_list}


*** Keywords ***
Verify Libraries In Base Image    # robocop: disable
    [Documentation]    Fetches library versions from JH spawner and checks
    ...    they match the installed versions.
    [Arguments]    ${img}    ${additional_libs}
    @{list} =    Create List
    ${text} =    Fetch Image Description Info    ${img}
    Append To List    ${list}    ${text}
    ${tmp} =    Fetch Image Tooltip Info    ${img}
    ${list} =    Combine Lists    ${list}    ${tmp}    # robocop: disable
    ${list} =    Combine Lists    ${list}    ${additional_libs}
    Log    ${list}
    Spawn Notebook With Arguments    image=${img}
    ${status} =    Check Versions In JupyterLab    ${list}
    Clean Up Server
    Stop JupyterLab Notebook Server
    Go To    ${ODH_DASHBOARD_URL}
    Wait For RHODS Dashboard To Load
    Launch Jupyter From RHODS Dashboard Link
    Fix Spawner Status
    Wait Until JupyterHub Spawner Is Ready
    [Return]    ${status}

Load Spawner Page
    [Documentation]    Suite Setup, loads JH Spawner
    Wait Until All Builds Are Complete    namespace=redhat-ods-applications    build_timeout=45m
    Begin Web Test
    Launch JupyterHub Spawner From Dashboard

Verify List Of Libraries In Image
    [Documentation]    It checks that libraries are installed or not in ${image} image
    [Arguments]    ${image}    @{additional_libs}
    ${status} =    Verify Libraries In Base Image    ${image}    ${additional_libs}
    Append To List    ${status_list}    ${status}
    Run Keyword If    '${status}' == 'FAIL'    Fail    Shown and installed libraries for ${image} image do not match
