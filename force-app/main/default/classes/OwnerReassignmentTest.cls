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
@isTest
private class OwnerReassignmentTest {
    @isTest
    static void testBatchAccountOwnerReassignment() {
        // Access the standard user profile&nbsp;

        Profile p = [SELECT Id FROM profile WHERE name = 'Standard User'];

        // Create the two users for the test

        User fromUser = new User(
            alias = 'newUser1',
            email = 'newuserA@testorg.com',
            emailencodingkey = 'UTF-8',
            lastname = 'Testing',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles',
            username = 'newuserA@testorg.com'
        );

        User toUser = new User(
            alias = 'newUser2',
            email = 'newuserB@testorg.com',
            emailencodingkey = 'UTF-8',
            lastname = 'Testing',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles',
            username = 'newuserB@testorg.com'
        );

        insert fromUser;
        insert toUser;

        // Use the new users to create a new account&nbsp;

        List<Account> accs = new List<Account>();
        for (integer i = 0; i < 200; i++) {
            accs.add(new Account(name = 'test', ownerId = fromUser.id));
        }
        insert accs;

        // Actually start the test

        Test.startTest();
        Database.executeBatch(new OwnerReassignment(fromUser, toUser));
        Test.stopTest();

        // Verify the test worked

        accs = [SELECT id, name FROM account WHERE ownerId = :toUser.id];
        System.assert(accs.size() == 200);
    }
}
