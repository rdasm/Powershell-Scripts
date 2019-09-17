Sub Download_Outlook_Mail_To_Excel()
'Add Tools->References->"Microsoft Outlook nn.n Object Library"
'nn.n varies as per our Outlook Installation
Dim folders As Outlook.folders
Dim folder As Outlook.folder
Dim iRow As Integer
Dim Pst_Folder_Name
Dim MailboxName
Dim subFolderName
Dim MyRestrictions As Outlook.items



'Mailbox or PST Main Folder Name (As how it is displayed in your Outlook Session)
MailboxName = "rdasm@example.com"

'Mailbox Folder or PST Folder Name (As how it is displayed in your Outlook Session)
Pst_Folder_Name = "Inbox"

'SubFolder name
subFolderName = "Alerts"

Set folder = Outlook.Session.folders(MailboxName).folders(Pst_Folder_Name).folders(subFolderName)
'folder.Items.Restrict ("[ReceivedTime] >= '" & DateValue("2018-03-01") & "' AND [ReceivedTime] <= '" & DateValue("2018-04-01") & "'")
'MsgBox DateValue(Now)

If folder = "" Then
    MsgBox "Invalid Data in Input"
    GoTo end_lbl1:
End If

'Set MyRestrictions = folder.items.Restrict("[ReceivedTime] >= '" & DateValue("2018-03-01 00:00:00 AM") & "' AND [ReceivedTime] <= '" & DateValue("2018-04-01 00:00:00 AM") & "'")
'Read Through each Mail and export the details to Excel for Email Archival

'MsgBox MyRestrictions.Count


'For iRow = 2 To folder.Items.Count
Sheets(1).Activate
'For iRow = 1 To MyRestrictions.Count
For iRow = 1 To folder.items.Count
 With folder.items(iRow)
     Sheets(1).Cells(iRow + 1, 1).Select
    Sheets(1).Cells(iRow + 1, 1) = .ReceivedTime
    Sheets(1).Cells(iRow + 1, 2) = .Subject
    Sheets(1).Cells(iRow + 1, 3) = .SenderEmailAddress
    Sheets(1).Cells(iRow + 1, 4) = .To
    Sheets(1).Cells(iRow + 1, 5) = .CC
    Sheets(1).Cells(iRow + 1, 6) = .BCC
    Sheets(1).Cells(iRow + 1, 7) = .Attachments.Count
    'Sheets(1).Cells(iRow + 1, 8) = Folder.Items.Item(iRow).Size
    'Sheets(1).Cells(iRow + 1 , 9) = Folder.Items.Item(iRow).Body
End With

Next iRow

MsgBox "Outlook Mails Extracted to Excel"

end_lbl1:

End Sub


