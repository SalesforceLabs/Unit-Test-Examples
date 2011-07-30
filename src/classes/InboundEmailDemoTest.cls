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
private class InboundEmailDemoTest {

	static testMethod void testTasks() {

	// Create a new email and envelope object
	   Messaging.InboundEmail email = new Messaging.InboundEmail();
	   Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

	// Create the plainTextBody and fromAddress for the test
		email.plainTextBody = 'Here is my plainText body of the email';
		email.fromAddress ='janedoe@testdoeorg.com';
	
	

		InboundEmailDemo demoObj = new InboundEmailDemo();
		demoObj.handleInboundEmail(email, env);
	
		// set up Account and Contact to test that a
		// task gets created
        Account acc = new Account();
        acc.BillingCountry = 'US';
        acc.ShippingCountry = 'US';
        acc.BillingState = 'IL';        
        acc.Name = 'Test Acc';
        insert acc;
	
		Contact con = new Contact();
		con.FirstName = 'Jane';
		con.LastName = 'Doe';
		con.Email = 'janedoe@testdoeorg.com';
		con.AccountId = acc.Id;
		insert con;
		
		//now try again
		demoObj = new InboundEmailDemo();
		demoObj.handleInboundEmail(email, env);
		
		//make sure task was inserted
		List<Task> demoTasks = [Select Id From Task Where WhoId=:con.Id];
		System.assertEquals(1,demoTasks.size());
	
	} 
}