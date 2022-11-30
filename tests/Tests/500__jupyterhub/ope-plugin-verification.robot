*** Settings ***
Library         SeleniumLibrary
Library         Collections
Library         JupyterLibrary
Library         String
Resource        ../../Resources/Page/LoginPage.robot
Resource        ../../Resources/Page/ODH/ODHDashboard/ODHDashboard.robot
Resource        ../../Resources/Page/ODH/JupyterHub/ODHJupyterhub.resource
Resource        ../../Resources/RHOSi.resource
Suite Setup     Plugin Testing Suite Setup
Suite Teardown   Plugin Testing Suite Teardown
Force Tags       JupyterHub

*** Variables ***
${ope_image}            byon-1669072197263
@{notebook_images}             ${ope_image}
@{ope}    @jupyterlab/git      jupyterlab_pygments      jupyterlab-jupytext      jupyterlab-myst      nbdime-jupyterlab      rise-jupyterlab      @agoose77/jupyterlab-markup      @deathbeds/ipydrawio      @deathbeds/ipydrawio-jupyter-templates      @deathbeds/ipydrawio-notebook      @deathbeds/ipydrawio-pdf      @deathbeds/ipydrawio-webpack      @ijmbarr/jupyterlab_spellchecker      @jupyter-widgets/jupyterlab-manager      Python 3.10
&{temporary_data}
&{image_mismatch_plugins}

*** Test Cases ***
Test User Notebook Plugin in JupyterLab
    [Tags]  Sanity
    ...     ODS-486
    ...     ProductBug
    Gather Notebook data
    Open Browser  ${ODH_DASHBOARD_URL}  browser=${BROWSER.NAME}  options=${BROWSER.OPTIONS}
    Login To RHODS Dashboard  ${TEST_USER.USERNAME}  ${TEST_USER.PASSWORD}  ${TEST_USER.AUTH_TYPE}
    Launch JupyterHub Spawner From Dashboard
    ${authorization_required} =  Is Service Account Authorization Required
    Run Keyword If  ${authorization_required}  Authorize jupyterhub service account
    Remove All Spawner Environment Variables
    Get the List of Plugins from RHODS notebook images
    Verify the Plugins for each JL images
    Run Keyword IF     ${image_mismatch_plugins} != &{EMPTY}   Fail    Plugin mismatch Found in the mentioned images '${image_mismatch_plugins}'
    ...       ELSE      Log To Console   All the plugin is matched between the old and new notebook images

*** Keywords ***
Plugin Testing Suite Setup
   Set Library Search Order  SeleniumLibrary
   RHOSi Setup
   ${notebook_pod_name}         Get User Notebook Pod Name         ${TEST_USER.USERNAME}
   Set Suite Variable     ${notebook_pod_name}

Plugin Testing Suite Teardown
   SeleniumLibrary.Close All Browsers
   Run Keyword And Return Status    Run   oc delete pod ${notebook_pod_name} -n rhods-notebooks

Gather Notebook data
   ${notebook_data}             Create Dictionary          ${ope_image}=${ope}
   Set Suite Variable     ${notebook_data}
   Run Keyword And Return Status    Run   oc delete pod ${notebook_pod_name} -n rhods-notebooks

Get the List of Plugins from RHODS notebook images
  FOR  ${image}  IN  @{notebook_images}
      Spawn Notebook With Arguments  image=${image}   size=Small
      #${notebook_pod_name}         Get User Notebook Pod Name         ${TEST_USER.USERNAME}
      ${temp_data}      Get Install Plugin list from JupyterLab
      ${py_version_message}    Run   oc exec ${notebook_pod_name} -n rhods-notebooks -- python --version
      ${py_version}           Split String From Right	  ${py_version_message}  	\n    1
      ${python_image}         Split String From Right	  ${py_version}[-1]  	.    1
      Append To List           ${temp_data}         ${python_image}[0]
      Log    ${temp_data}
      Set To Dictionary   ${temporary_data}      ${image}     ${temp_data}
      Stop JupyterLab Notebook Server
      Sleep  3
  END

Verify the Plugins for each JL images
   FOR  ${image}  IN  @{notebook_images}
        ${mistamtch_plugins}    Create List
        ${plugin_names}     Get From Dictionary	   ${temporary_data}     ${image}
        ${old_notebok_plugin}      Get From Dictionary	   ${notebook_data}     ${image}
        IF    len(${plugin_names}) >= len(${old_notebok_plugin})
              FOR    ${name}    IN    @{plugin_names}
                     Run Keyword If      $name not in $old_notebok_plugin    Append To List    ${mistamtch_plugins}    ${name}
                     ...       ELSE      Log    Plugin '${name}' has not changed
              END
              Run Keyword IF   ${mistamtch_plugins} != @{EMPTY}   Set To Dictionary    ${image_mismatch_plugins}        ${image}     ${mistamtch_plugins}
        ELSE
              ${missing_plugins}    Create List
              FOR    ${name}    IN    @{old_notebok_plugin}
                     Run Keyword If      $name not in $plugin_names   Append To List    ${missing_plugins}    ${name}
              END
              Run Keyword And Continue On Failure          FAIL       Plugins '${missing_plugins}' has been removed from the '${image}' notebook image
        END

   END
