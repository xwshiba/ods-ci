# ODS-CI OPE (Open Source Education)

ODS-CI is a framework to test Red Hat Open Data Science features and functionality
using QE tiered testing. ODS-CI ope-test branch includes 6 extra tests for [OPE (Open Source Education) test image](https://github.com/xwshiba/ope/tree/container-burosa-test) in `ods-ci/tests/Tests/500__jupyterhub`.

 - ope-test-jupyterlab-git-testbook.robot
 - ope-test-versions.robot
 - ope-plugin-verification.robot
 - ope-test-folder-permissions.robot
 - ope-test-filling-pvc.robot
 - ope-test-jupyterlab-time.robot

# Requirements
  Linux distribution that supports Selenium automation of a chromium web browser using [ChromeDriver](https://chromedriver.chromium.org)
  * chromedriver binaries can be downloaded from https://chromedriver.chromium.org/downloads. The chromedriver version must match the installed version of chromium/google-chrome

# Quick Start
  1. Create a variables file for all of the global test values
     ```bash
     # Create the initial test variables from the example template variables file
     cp test-variables.yml.example test-variables.yml
     ```

  1. Edit the test variables file to include information required for this test run.
     You will need to add info required for test execution:

     * URLs based on the test case you are executing.<br>
        ** OpenShift Console.<br>
        ** Open Data Hub Dashboard.<br>
        ** JupyterHub.<br>
     * Test user credentials.
     * Browser webdriver to use for testing.


  1. Run this script that will create the virtual environment, install the required packages and kickoff the Robot test suite
    ```bash
    sh run_robot_test.sh
    ```
    This script is a wrapper for creating the python virtual environment and running the Robot Framework CLI.  You can run any of the test cases by creating the python virual environment, install the packages in requirements.txt and running the `robot` command directly

 # Common Errors and Solutions

 Some errors may come up when developing new tests. Here are the common error types:
 - RHODS front-end UI difference between versions;
 - Test account not clean up due to previous failure;
 - Missing user Interaction steps in test files.

 Solution for the above errors:
 - Check latest front-end;
 - Manually clean up the test account;
 - Check existing resources or add missing interaction steps.

# More Questions
If you have more questions regarding OPE tests, please let us know through opening an issue. 
Otherwise, please direct your question to the upstream ods-ci.
