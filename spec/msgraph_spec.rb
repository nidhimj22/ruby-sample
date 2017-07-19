require 'adal'
require 'net/http'
require 'uri'
require 'rubygems'
require 'base64'
require 'httparty'
require 'json'



describe HelloWorld do 
   context "When testing the MSGraph API" do 
      
      it "should say 'Hello World' when we call the say_hello method" do 
	AUTHORITY_HOST = ADAL::Authority::WORLD_WIDE_AUTHORITY
	RESOURCE = 'https://graph.microsoft.com'
	TENANT = 'cpimtestabhiagr.onmicrosoft.com'
	username1 = "nidhi@cpimtestabhiagr.onmicrosoft.com"#prompt 'Username: '
	password1 = "Hudu58201" #prompt 'Password: '
	CLIENT_ID1 = 'f6592ba3-60af-4ffa-b7e0-d31abb3b1216'
	user_cred1 = ADAL::UserCredential.new(username1, password1)
	ctx1 = ADAL::AuthenticationContext.new(AUTHORITY_HOST, TENANT)
	result1 = ctx1.acquire_token_for_user(RESOURCE, CLIENT_ID1, user_cred1)
	b2CPolicies_endpoint = "https://graph.microsoft.com/testcpim/b2cPolicies"
	identityProviders_endpoint = "https://graph.microsoft.com/testcpim/identityProviders"


	case result1
		when ADAL::SuccessResponse
			api_auth_header1 = {"Authorization" => "Bearer #{result1.access_token}"}
			response = HTTParty.get(b2CPolicies_endpoint, headers: api_auth_header1)
			response = response.parsed_response["value"]
			puts response
			expect(response).to be_an_instance_of(Array)
		when ADAL::FailureResponse
			puts 'Failed to authenticate with client credentials. Received error: ' "#{result1.error} and error description: #{result1.error_description}."
		else
			puts "land of no return"
	end					
      end   
   end
end