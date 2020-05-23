/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
global class InboundEmailDemo implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.inboundEmail email,
        Messaging.InboundEnvelope env
    ) {
        // Create an inboundEmailResult object for returning
        // the result of the Force.com Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        String myPlainText = '';

        // Add the email plain text into the local variable

        try {
            myPlainText = email.plainTextBody.substring(
                0,
                email.plainTextBody.indexOf('<stop>')
            );
        } catch (System.StringException e) {
            myPlainText = email.plainTextBody;
            System.debug('No <stop> in email: ' + e);
        }

        // new Task object to be created

        Task[] newTask = new List<Task>(0);

        // Try to lookup any contacts based on the email from address
        // If there is more than 1 contact with the same email address
        // an exception will be thrown and the catch statement will be called
        try {
            Contact vCon = [
                SELECT Id, Name, Email
                FROM Contact
                WHERE Email = :email.fromAddress
                LIMIT 1
            ];

            // Add a new Task to the contact record we just found above
            newTask.add(
                new Task(
                    Description = myPlainText,
                    Priority = 'Normal',
                    Status = 'Inbound Email',
                    Subject = email.subject,
                    IsReminderSet = true,
                    ReminderDateTime = System.now() + 1,
                    WhoId = vCon.Id
                )
            );

            // Insert the new Task and it will be created and appended to the contact record
            insert newTask;

            System.debug('New Task Object: ' + newTask);
        } catch (System.QueryException e) {
            // If there is an exception with the query looking up
            // the contact this QueryException will be called.
            // and the exception will be written to the Apex Debug logs

            System.debug('Query Issue: ' + e);
        }

        // Set the result to true, no need to send an email back to the user
        // with an error message

        result.success = true;

        // Return the result for the Force.com Email Service
        return result;
    }
}
