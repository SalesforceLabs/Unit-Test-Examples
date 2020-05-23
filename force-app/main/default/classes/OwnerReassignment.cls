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
global class OwnerReassignment implements Database.Batchable<SObject>, Database.Stateful {
    User fromUser { get; set; }
    User toUser { get; set; }

    global OwnerReassignment(User fromUser, User toUser) {
        this.fromUser = fromUser;
        this.toUser = toUser;
    }

    global Database.queryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(
            [SELECT id, name, ownerId FROM Account WHERE ownerId = :fromUser.id]
        );
    }

    global void execute(Database.BatchableContext ctx, List<Account> accs) {
        for (Account acc : accs) {
            acc.ownerId = toUser.id;
        }

        update accs;
    }

    global void finish(Database.BatchableContext ctx) {
        AsyncApexJob a = [
            SELECT
                id,
                ApexClassId,
                JobItemsProcessed,
                TotalJobItems,
                NumberOfErrors,
                CreatedBy.Email
            FROM AsyncApexJob
            WHERE id = :ctx.getJobId()
        ];

        String emailMessage =
            'Your batch job ' +
            'AccountOwnerReassignment ' +
            'has finished.  It executed ' +
            a.totalJobItems +
            ' batches.  Of which, ' +
            a.jobitemsprocessed +
            ' processed without any exceptions thrown and ' +
            a.numberOfErrors +
            ' batches threw unhandled exceptions.';

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>{ a.createdBy.email };
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Batch Job Summary');
        mail.setSubject('Batch job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
}
