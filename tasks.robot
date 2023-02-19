*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.PDF
Library             RPA.Tables
Library             RPA.RobotLogListener
Library             RPA.Archive
Library             RPA.Dialogs
Library             RPA.Robocorp.Vault
Variables           variables.py


*** Variables ***
${PDF_TEMP_OUTPUT_DIRECTORY}=       ${CURDIR}${/}temp
${ORDER_QUANTITY}                   5


*** Tasks ***
Get and log the value of the vault secrets using the Get Secret keyword
    ${secret}=    Get Secret    credentials
    Log    ${secret}[username]
    Log    ${secret}[password]

Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Download the orders file
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the recipts


*** Keywords ***
Open the robot order website
    #${credentials}=    Get Secret    robotsparebinindustries
    Open Available Browser    ${ORDER_URL}
    Log    ${USER_NAME}
    Log    ${PASSWORD}
    Maximize Browser Window
    Log    Order successful! Ordered ${ORDER_QUANTITY} robots.

Get and log the value of the vault secrets using the imported variables file
    Log    ${USER_NAME}
    Log    ${PASSWORD}

Close the annoying modal
    Click Button    OK

Fill the form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    css:input[class="form-control"]    ${row}[Legs]
    Input Text    address    ${row}[Address]

Preview the robot
    Click Button    preview

Submit the order
    Wait Until Keyword Succeeds    5x    2s    Order Item

Order Item
    Click Button    order
    Mute Run On Failure    Wait Until Page Contains Element
    Wait Until Page Contains Element    receipt    1

Download the orders file
    ${result}=    Input form dialog
    ${path}=    Convert To String    ${result.location}
    ${path}=    set variable    ${ORDERFILE_URL}
    Download    ${path}    overwrite=True
    ${orders}=    Read table from CSV    orders.csv    true
    RETURN    ${orders}

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    Wait Until Element Is Visible    receipt
    ${order_html}=    Get Element Attribute    id:receipt    outerHTML
    ${file}=    set variable    ${PDF_TEMP_OUTPUT_DIRECTORY}${/}order_number_${order_number}.pdf
    Html To Pdf    ${order_html}    ${file}
    RETURN    ${file}

Take a screenshot of the robot
    [Arguments]    ${order_number}
    ${file}=    set variable    ${OUTPUT_DIR}${/}robot_preview_${order_number}.png
    Screenshot    robot-preview-image    ${file}
    RETURN    ${file}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    ${files}=    Create List    ${screenshot}
    Add Files To Pdf    ${files}    ${pdf}    True

Go to order another robot
    Click Button    order-another

Create a ZIP file of the recipts
    ${zipname}=    Set Variable    ${OUTPUT_DIR}${/}PDFs.zip
    Archive Folder With Zip    ${PDF_TEMP_OUTPUT_DIRECTORY}    ${zipname}

Input form dialog
    Add heading    URL for Orders
    Add text input    location    label=URL of Orders info
    ${result}=    Run dialog
    RETURN    ${result}
