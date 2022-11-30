*** Settings ***
Documentation       Test Suite to check the folder permissions

Resource            ../../Resources/ODS.robot
Resource            ../../Resources/Common.robot
Resource            ../../Resources/Page/ODH/JupyterHub/ODHJupyterhub.resource
Resource            ../../Resources/Page/OCPDashboard/Builds/Builds.robot

Library             JupyterLibrary

Suite Setup         Load Spawner Page
Suite Teardown      End Web Test


*** Variables ***
${ope_image}            byon-1669072197263
@{LIST_OF_IMAGES} =    ${ope_image}
@{EXPECTED_PERMISSIONS} =       2775    0    1001020000
@{FOLDER_TO_CHECK} =            /opt/app-root/src


*** Test Cases ***
Verify Folder Permissions
    [Documentation]    Checks Access, Uid, Gid of /opt/app-root/src
    [Tags]    ODS-486
    ...       Tier2
    Verify Folder Permissions For Images    image_list=${LIST_OF_IMAGES}
    ...    folder_to_check=${FOLDER_TO_CHECK}    expected_permissions=${EXPECTED_PERMISSIONS}


*** Keywords ***
Load Spawner Page
    [Documentation]    Suite Setup, loads JH Spawner
    Wait Until All Builds Are Complete    namespace=redhat-ods-applications    build_timeout=45m
    Begin Web Test
    Launch JupyterHub Spawner From Dashboard

Verify The Permissions Of Folder In Image
    [Documentation]    It verifies the ${permission} permissions of ${paths} folder in ${image} image
    [Arguments]    ${image}    ${paths}    ${permission}
    Spawn Notebook With Arguments    image=${image}
    FOR    ${path}    IN    @{paths}
        Verify The Permissions Of Folder    ${path}    @{permission}
    END
    Clean Up Server
    Stop JupyterLab Notebook Server
    Go To    ${ODH_DASHBOARD_URL}
    Wait For RHODS Dashboard To Load
    Launch Jupyter From RHODS Dashboard Link
    Fix Spawner Status
    Wait Until JupyterHub Spawner Is Ready

Verify The Permissions Of Folder
    [Documentation]    It checks for the folder permissions ${permission}[0], ${permission}[1], ${permission}[2]
    ...                should be of Access, Uid and Gid respectively. Change Gid according to your ope image requirement.
    [Arguments]    ${path}    @{permission}
    Run Keyword And Continue On Failure
    ...    Run Cell And Check Output
    ...    !stat ${path} | grep Access | awk '{split($2,b,"."); printf "%s", b[1]}' | awk '{split($0, c, "/"); printf c[1]}' | cut -c 2-5
    ...    ${permission}[0]
    Run Keyword And Continue On Failure
    ...    Run Cell And Check Output
    ...    !stat ${path} | grep Uid | awk '{split($5,b,"."); printf "%s", b[1]}' | awk '{split($0, c, "/"); printf c[1]}'
    ...    ${permission}[1]
    Run Keyword And Continue On Failure
    ...    Run Cell And Check Output
    ...    !stat ${path} | grep Gid | awk '{split($8,b,"."); printf "%s", b[1]}' | awk '{split($0, c, "("); printf c[2]}' | awk '{split($0, d, "/"); printf d[1]}'
    ...    ${permission}[2]

Verify Folder Permissions For Images
    [Documentation]    Checks the folder permissions in each image
    [Arguments]    ${image_list}    ${folder_to_check}    ${expected_permissions}
    FOR    ${img}    IN    @{image_list}
        Verify The Permissions Of Folder In Image    ${img}    ${folder_to_check}    ${expected_permissions}
    END
