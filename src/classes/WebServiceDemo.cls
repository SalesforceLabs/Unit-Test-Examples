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
public with sharing class WebServiceDemo {

	public String firstItem ='' ;
	
	public WebServiceDemo()
	{
	 	
	}
	
	public HttpRequest buildWebServiceRequest(){

	    //Build HTTP Request object
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint('http://samplewebservices.replaceme');
	    req.setMethod('GET');
	    return req;
	}

	public HttpResponse invokeWebService(Http h, HttpRequest req){  
	     //Invoke Web Service
	     HttpResponse res = h.send(req);
	     return res;
	}


	public void handleWebServiceResponse(HttpResponse res){

     //Parse and apply logic to the res message
         XmlStreamReader reader = res.getXmlStreamReader();

    	// Read through the XML  
    	// just taking the first item in the XML as test data
   		 while(reader.hasNext()) {
    	 
     		 if (reader.getEventType() == XmlTag.START_ELEMENT) {
       			firstItem = (reader.getLocalName());
       			return;
      		}
   	   		reader.next();
    	  }

	}


	public void main(){

	   //apply business logic
	   //now need to make web service callout

 
	   //First, build the http request
	   Http h = new Http();
	   HttpRequest req = buildWebServiceRequest();
    
		//Second, invoke web service call
	   HttpResponse res = invokeWebService(h, req);

    

	   //Last, handling the response
	   handleWebServiceResponse(res);

	}

  static testMethod void webserviceTest() {
        
		WebServiceDemo demo = new WebServiceDemo();
		
      //First, build the http request
      HttpRequest req = demo.buildWebServiceRequest();

      //NOTE - WE DO NOT EXECUTE THE METHOD, invokeWebService.
       

      //Now, since we can't execute the actual web service,
      //write apex code to build a sample HttpResponse object
      HttpResponse res = new HttpResponse();
      
        //Apply test data and attributes to the HttpResponse object as needed
      res.setBody('<note><to>Jane</to><from>Sally</from><heading>Reminder</heading><body>Remember to call Acme</body></note>');
    
      demo.handleWebServiceResponse(res);
	  System.assertEquals('note',demo.firstItem);
	  
    }

}