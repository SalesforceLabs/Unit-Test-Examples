@isTest
class WebServiceDemoTest {
    @isTest
    static void webserviceTest() {
        WebServiceDemo demo = new WebServiceDemo();

        //First, build the http request
        HttpRequest req = demo.buildWebServiceRequest();

        //NOTE - WE DO NOT EXECUTE THE METHOD, invokeWebService.

        //Now, since we can't execute the actual web service,
        //write apex code to build a sample HttpResponse object
        HttpResponse res = new HttpResponse();

        //Apply test data and attributes to the HttpResponse object as needed
        res.setBody(
            '<note><to>Jane</to><from>Sally</from><heading>Reminder</heading><body>Remember to call Acme</body></note>'
        );

        demo.handleWebServiceResponse(res);
        System.assertEquals('note', demo.firstItem);
    }
}
