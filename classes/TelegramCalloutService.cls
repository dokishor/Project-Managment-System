public class TelegramCalloutService {

    private HttpRequest request;
    private HttpResponse response;
    private static String TELEGRAM_API_ENDPOINT = 'https://api.telegram.org/bot';
    private static String API_TOKEN = '5003462303:AAHON-YtecDpo5NH3237N4vZQlJ6vYEscNk';


    private Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json'};

    private String endpoint = 'https://api.telegram.org/bot' + API_TOKEN;

    public TelegramCalloutService(){
        this.request = new HttpRequest();
    }


    public void setHeaders(Map<String, String> headers){
        if(headers != null && !headers.isEmpty()){
            this.headers.putAll(headers);
        }
    }


    public void setBody(String body){
        this.request.setBody(body);
    }


    public HttpResponse getMe(){
        this.endpoint += '/getMe';
        this.request.setEndpoint(this.endpoint);
        this.request.setMethod('GET');
        return this.sendRequest();

    }

    public HttpResponse sendMessage(){
        this.endpoint += '/sendMessage';
        this.request.setEndpoint(this.endpoint);
        this.request.setMethod('POST');
        return sendRequest();
    }

    public HttpResponse getUpdates(){
        this.endpoint += '/getUpdates';
        this.request.setEndpoint(this.endpoint);
        this.request.setMethod('GET');
        return sendRequest();
    }


    private HttpResponse sendRequest(){
        Http http = new Http();
        System.debug('response.getBody(): ' + this.request.getBody());
        this.response = http.send(this.request);
        return this.response;
    }

    private void handleResponse(){}
}