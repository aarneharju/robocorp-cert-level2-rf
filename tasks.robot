*** Settings ***
Documentation      Robot ordering automatron filling order data from order file

Suite Setup        Setup browser
Suite Teardown     Close browser

Library            RPA.Browser.Playwright
Library            RPA.HTTP
Library            RPA.PDF
Library            RPA.Robocorp.Vault
Library            RPA.Tables

*** Variables ***
${GLOBAL_RETRY_AMOUNT}=      3x
${GLOBAL_RETRY_INTERVAL}=    1s
${order_not_successful}=     0             

*** Tasks ***
Download the order file and complete the order form
    Open the robot order website                  https://robotsparebinindustries.com/#/robot-order
    Download the order data                       https://robotsparebinindustries.com/orders.csv
    #Login Maria
    Loop and fill the form with the order data    files/orders.csv
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

Loop and fill the form with the order data
    [Arguments]    ${order_data}
    ${orders}=    Read table from CSV    ${order_data}    header=True
    
    FOR    ${order}    IN    @{orders}
        Select head        ${order}
        Select body        ${order}
        Select legs        ${order}
        Select address     ${order}
        Submit the order
        ${order_not_successful}=    RPA.Browser.Playwright.Get Element Count    //button[@id="order"]
        WHILE    ${order_not_successful} == 1
            Submit the order
            ${order_not_successful}=    RPA.Browser.Playwright.Get Element Count    //button[@id="order"]
        END
        Convert order receipt html page to PDF
        Order another robot
        Click ok on the popup
    END

Select head
    [Arguments]    ${order}
    RPA.Browser.Playwright.Select Options By    //*[@id="head"]    index    ${order}[Head]

Select body
    [Arguments]    ${order}
    RPA.Browser.Playwright.Click                //input[@id="id-body-1"]

Select legs
    [Arguments]    ${order}
    RPA.Browser.Playwright.Click                //input[@placeholder="Enter the part number for the legs"]
    RPA.Browser.Playwright.Keyboard Input       insertText    ${order}[Legs]
Select address
    [Arguments]    ${order}
    RPA.Browser.Playwright.Click                //input[@id="address"]
    RPA.Browser.Playwright.Keyboard Input       insertText    ${order}[Address]

Submit the order
    RPA.Browser.Playwright.Click                //button[@id="order"]

Save the receipt as a string
    RPA.Browser.Playwright.Get Text    //div[@id="receipt"]    output_path=${CURDIR}/output/order_receipt.html

Convert order receipt html page to PDF
    RPA.Browser.Playwright.Wait For Elements State    //div[@id="receipt"]    visible    timeout=10s
    #${attributes}    RPA.Browser.Playwright.Get Attribute Names    //div[@id="receipt"]
    #Log    ${attributes}
    ${content}=    RPA.Browser.Playwright.Get Property    //div[@id="receipt"]    outerHTML
    RPA.PDF.Html To Pdf    ${content}    ${CURDIR}/output/order_receipt.pdf

Save the order receipt as a PNG file
    RPA.Browser.Playwright.Take Screenshot   //div[@id="receipt"]    ${CURDIR}/output/order_receipt.png

Order another robot
    RPA.Browser.Playwright.Wait For Elements State    //button[@id="order-another"]    visible    10
    RPA.Browser.Playwright.Click                //button[@id="order-another"]
    #${order_not_successful}=    Set Variable    0

Click ok on the popup
    RPA.Browser.Playwright.Click                text=OK

Close browser
    RPA.Browser.Playwright.Close Browser

Get credentials from Vault
    ${secret}=    Get Secret    credentials