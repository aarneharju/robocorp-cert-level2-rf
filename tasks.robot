*** Settings ***
Documentation       Robot ordering automaatron

Suite Setup         Setup browser
Suite Teardown      Close browser

Library             RPA.Browser.Playwright
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Robocorp.Vault


*** Tasks ***
Donwnload the order file and complete the order form
    Open the robot order website                  https://robotsparebinindustries.com/#/robot-order
    Download the order data                       https://robotsparebinindustries.com/orders.csv
    #Login Maria
    #Loop and fill the form with the order data    orders.csv
    #Archive output as PDF

*** Keywords ***
Setup browser
    New Browser    headless=false    downloadsPath=files
    New Context    acceptDownloads=true    viewport={'width': 1920, 'height': 1080}

Open the robot order website
    [Arguments]   ${url}
    RPA.Browser.Playwright.New Page      ${url}
    Wait For Elements State    css=.alert-buttons    visible
    Click    text=OK

Login Maria
    ${login_credentials}=    Get Secret    RobotSpareBinIndustriesLoginCredentials   
    

Download the order data
    [Arguments]    ${url}
    #${order_data}=    RPA.Browser.Playwright.Download    ${url}
    RPA.HTTP.Download    ${url}    target_file=files/orders.csv    overwrite=True

Close browser
    RPA.Browser.Playwright.Close Browser

Get credentials from Vault
    ${secret}=    Get Secret    credentials