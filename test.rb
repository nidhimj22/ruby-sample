require 'adal'
require 'net/http'
require 'uri'
require 'rubygems'
require 'base64'
require 'httparty'
require 'json'

# This will make ADAL log the various steps of obtaining an access token.
#ADAL::Logging.log_level = ADAL::Logger::VERBOSE

AUTHORITY_HOST = ADAL::Authority::WORLD_WIDE_AUTHORITY
RESOURCE = 'https://graph.microsoft.com'

def prompt(*args)
  print(*args)
  gets.strip
end

TENANT1 = 'cpimtestabhiagr.onmicrosoft.com'
username1 = "nidhi@cpimtestabhiagr.onmicrosoft.com"#prompt 'Username: '
password1 = "Hudu58201" #prompt 'Password: '
CLIENT_ID1 = 'f6592ba3-60af-4ffa-b7e0-d31abb3b1216'


TENANT2 = 'NidhiTenant1.onmicrosoft.com'
username2 = "chris@NidhiTenant1.onmicrosoft.com"#prompt 'Username: '
password2 = "Jomo87081" #prompt 'Password: '
CLIENT_ID2 = '27ea6d6c-a478-4ab4-91ef-5664d2ac03fd'


user_cred1 = ADAL::UserCredential.new(username1, password1)
user_cred2 = ADAL::UserCredential.new(username2, password2)


ctx1 = ADAL::AuthenticationContext.new(AUTHORITY_HOST, TENANT1)
ctx2 = ADAL::AuthenticationContext.new(AUTHORITY_HOST, TENANT2)

result1 = ctx1.acquire_token_for_user(RESOURCE, CLIENT_ID1, user_cred1)
result2 = ctx2.acquire_token_for_user(RESOURCE, CLIENT_ID2, user_cred2)


b2CPolicies_endpoint = "https://graph.microsoft.com/testcpim/b2cPolicies"
identityProviders_endpoint = "https://graph.microsoft.com/testcpim/identityProviders"


case result1
	when ADAL::SuccessResponse
		case result2
			when ADAL::SuccessResponse
				api_auth_header1 = {"Authorization" => "Bearer #{result1.access_token}"}
				api_auth_header2 = {"Authorization" => "Bearer #{result2.access_token}"}

		puts "*********Print and delete all B2CPolicies in tenant1*********"
		response = HTTParty.get(b2CPolicies_endpoint, headers: api_auth_header1)
		response["value"].each do |item|
			s = item["id"]
			puts s
			
			uri = URI.parse("#{b2CPolicies_endpoint}(%27#{s}%27)")
			#puts uri
			
			request = Net::HTTP::Delete.new(uri)
			request["Authorization"] = "Bearer #{result1.access_token}"
			req_options = {
		  		use_ssl: uri.scheme == "https",
			}
		
			res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  		http.request(request)
			end
			puts res.code#, res.message
		end
		
		
		puts "*********Print and delete all B2CPolicies in tenant2*********"
		response = HTTParty.get(b2CPolicies_endpoint, headers: api_auth_header2)
		response["value"].each do |item|
			s = item["id"]
			puts s
			
			uri = URI.parse("#{b2CPolicies_endpoint}(%27#{s}%27)")
			#puts uri
			
			request = Net::HTTP::Delete.new(uri)
			request["Authorization"] = "Bearer #{result2.access_token}"
			req_options = {
		  		use_ssl: uri.scheme == "https",
			}
		
			res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  		http.request(request)
			end
			puts res.code#, res.message
		end
		
		
		puts "*********Print and delete all IdentityProviders in tenant1*********"	
		response = HTTParty.get(identityProviders_endpoint, headers: api_auth_header1)
		response["value"].each do |item|
			s = item["id"]
			puts s
		
			uri = URI.parse("#{identityProviders_endpoint}(%27#{s}%27)")
			#puts uri
			
			request = Net::HTTP::Delete.new(uri)
			request["Authorization"] = "Bearer #{result1.access_token}"
			req_options = {
		  		use_ssl: uri.scheme == "https",
			}
		

			res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  		http.request(request)
			end
			puts res.code#, res.code, res.message
		end


		puts "*********Print and delete all IdentityProviders in tenant2*********"	
		response = HTTParty.get(identityProviders_endpoint, headers: api_auth_header2)
		response["value"].each do |item|
			s = item["id"]
			puts s
		
			uri = URI.parse("#{identityProviders_endpoint}(%27#{s}%27)")
			#puts uri
			
			request = Net::HTTP::Delete.new(uri)
			request["Authorization"] = "Bearer #{result2.access_token}"
			req_options = {
		  		use_ssl: uri.scheme == "https",
			}
		

			res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  		http.request(request)
			end
			puts res.code#, res.code, res.message
		end




	puts "*********Create Google and facebook IDP in tenant1*********"	
		

	#create google-auth and facebook-oauth in both tenants
	uri = URI.parse(identityProviders_endpoint)
	request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
	request["Authorization"] = "Bearer #{result1.access_token}"
	req_options = {
		  use_ssl: uri.scheme == "https",
	}

	request.body = {'clientId'  => '1A143957-C34A-4405-89D6-72C348F82AE8' , 'type' => 'Google', 'clientSecret' => '34'}.to_json
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code, res.body

	request.body = {'clientId'  => '1A143957-C34A-4405-89D6-72C348F82AE8' , 'type' => 'Facebook', 'clientSecret' => '34'}.to_json
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code, res.body
	idp1 = res.body

    puts "*********Create Google and facebook IDP in tenant2*********"	
	
	request["Authorization"] = "Bearer #{result2.access_token}"
	request.body = {'clientId'  => '1A143957-C34A-4405-89D6-72C348F82AE8' , 'type' => 'Google', 'clientSecret' => '34'}.to_json
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code, res.body

	request.body = {'clientId'  => '1A143957-C34A-4405-89D6-72C348F82AE8' , 'type' => 'Facebook', 'clientSecret' => '34'}.to_json
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code, res.body
	idp2 = res.body
	
	puts "*********Patch Google IDP in tenant1*********"
	#patch a IDP in tenant1 and tenant2
		
	uri = URI.parse("#{identityProviders_endpoint}(%27Google-OAUTH%27)")
	request = Net::HTTP::Patch.new(uri)
	request.content_type = "application/json"
	request["Authorization"] = "Bearer #{result1.access_token}"
	request.body = {'name'  => 'changedGoogle' }.to_json
	
	req_options = {
  		use_ssl: uri.scheme == "https",
	}

	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end

	puts res.code


	puts "*********Patch Google IDP in tenant2*********"
	request["Authorization"] = "Bearer #{result2.access_token}"
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end

	puts res.code

	


	
    puts "*********Create B2CPolicies  in tenant1*********"
	
	#create b2cPolicies in both tenants
	uri = URI.parse(b2CPolicies_endpoint)
	request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
	request["Authorization"] = "Bearer #{result1.access_token}"
	req_options = {
		  use_ssl: uri.scheme == "https",
	}

	request.body = {'id'  => 'testSignUp' , 'type' => 'SignUp'}.to_json
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code, res.body


	request.body = {'id'  => 'testSignUpOrSignIn' , 'type' => 'SignupOrSignIn'}.to_json
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code, res.body

	request.body = {'id'  => 'testProfileUpdate' , 'type' => 'ProfileUpdate'}.to_json
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code, res.body
	
	puts "\n\n"

	puts "*********Create B2CPolicies  in tenant2*********"
	
	request["Authorization"] = "Bearer #{result2.access_token}"
	
	request.body = {'id'  => 'testSignUp' , 'type' => 'SignUp'}.to_json
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code, res.body


	request.body = {'id'  => 'testSignUpOrSignIn' , 'type' => 'SignupOrSignIn'}.to_json
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code, res.body

	request.body = {'id'  => 'testProfileUpdate' , 'type' => 'ProfileUpdate'}.to_json
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code, res.body
puts "\n\n"

	puts "*********Link testSignUpOrSignIn  b2CPolicy with Facebook OAUTH in tenant1*********"
	#link B2CPolicies to idps in both tenants 

	uri = URI.parse("#{b2CPolicies_endpoint}(%27B2C_1_testSignUpOrSignIn%27)/identityProviders/%24ref")
	puts uri
	request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
	
	request["Authorization"] = "Bearer #{result1.access_token}"

	request.content_type = "application/json"
	request.body = {'@odata.id' => "#{identityProviders_endpoint}(%27Facebook-OAUTH%27)"}.to_json
	req_options = {
  		use_ssl: uri.scheme == "https",
	}
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code
puts "\n\n"


	puts "*********Link testSignUpOrSignIn  b2CPolicy with Facebook OAUTH in tenant2*********"
	
	uri = URI.parse("#{b2CPolicies_endpoint}(%27B2C_1_testSignUpOrSignIn%27)/identityProviders/%24ref")
	request = Net::HTTP::Post.new(uri)
	request["Authorization"] = "Bearer #{result2.access_token}"

	request.content_type = "application/json"
	request.body = {'@odata.id' => "#{identityProviders_endpoint}(%27Facebook-OAUTH%27)"}.to_json
	req_options = {
  		use_ssl: uri.scheme == "https",
	}
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code

		puts "******Delete testProfileUpdate in tenant1******"
		uri = URI.parse("#{b2CPolicies_endpoint}(%27B2C_1_testProfileUpdate%27)")
			
			
			request = Net::HTTP::Delete.new(uri)
			request["Authorization"] = "Bearer #{result1.access_token}"
			req_options = {
		  		use_ssl: uri.scheme == "https",
			}
		
			res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  		http.request(request)
			end
			puts res.code

		puts "******Delete testProfileUpdate in tenant2******"
	request["Authorization"] = "Bearer #{result2.access_token}"
			
			res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  		http.request(request)
			end
			puts res.code

	puts "*********Link testSignUp b2CPolicy with Facebook OAUTH in tenant1*********"
	#link B2CPolicies to idps in both tenants 

	uri = URI.parse("#{b2CPolicies_endpoint}(%27B2C_1_testSignUp%27)/identityProviders/%24ref")
	puts uri
	request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
	
	request["Authorization"] = "Bearer #{result1.access_token}"

	request.content_type = "application/json"
	request.body = {'@odata.id' => "#{identityProviders_endpoint}(%27Facebook-OAUTH%27)"}.to_json
	req_options = {
  		use_ssl: uri.scheme == "https",
	}
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code


	puts "*********Link testSignUp b2CPolicy with Facebook OAUTH in tenant2*********"
	
	uri = URI.parse("#{b2CPolicies_endpoint}(%27B2C_1_testSignUp%27)/identityProviders/%24ref")
	request = Net::HTTP::Post.new(uri)
	request["Authorization"] = "Bearer #{result2.access_token}"

	request.content_type = "application/json"
	request.body = {'@odata.id' => "#{identityProviders_endpoint}(%27Facebook-OAUTH%27)"}.to_json
	req_options = {
  		use_ssl: uri.scheme == "https",
	}
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code

puts "*********Extra call to show difference in tenant1 and tenant2*********"
	

puts "*********Link testSignUpOrSignIn b2CPolicy with Google OAUTH in tenant2 only in tenant2*********"
	
	uri = URI.parse("#{b2CPolicies_endpoint}(%27B2C_1_testSignUpOrSignIn%27)/identityProviders/%24ref")
	request = Net::HTTP::Post.new(uri)
	request["Authorization"] = "Bearer #{result2.access_token}"

	request.content_type = "application/json"
	request.body = {'@odata.id' => "#{identityProviders_endpoint}(%27Google-OAUTH%27)"}.to_json
	req_options = {
  		use_ssl: uri.scheme == "https",
	}
	res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  		http.request(request)
	end
	puts res.code


	# get all B2CPolicies and idps in both tenants
		puts "*********Get all B2CPolicies and identity Providers from tenant1*********"	
		# get all B2CPolicies and identity Providers from tenant1

		puts "*********Print all B2CPolicies in tenant1*********"
		response = HTTParty.get("#{b2CPolicies_endpoint}?expand=identityProviders", headers: api_auth_header1)
		puts response.body#, response.code, response.message


		puts "*********Print all IdentityProviders in tenant1*********"	
		response = HTTParty.get(identityProviders_endpoint, headers: api_auth_header1)
		puts response.body#, response.code, response.message


		puts "*********Get all B2CPolicies and identity Providers from tenant2*********"	
		# get all B2CPolicies and identity Providers from tenant2

		puts "*********Print all B2CPolicies in tenant2*********"
		response = HTTParty.get("#{b2CPolicies_endpoint}?expand=identityProviders", headers: api_auth_header2)
		puts response.body#, response.code, response.message


		puts "*********Print all IdentityProviders in tenant2*********"	
		response = HTTParty.get(identityProviders_endpoint, headers: api_auth_header2)
		puts response.body#, response.code, response.message


	#prove equivalence
	#ask how?

			else
		end
		
when ADAL::FailureResponse
	puts 'Failed to authenticate with client credentials. Received error: ' "#{result1.error} and error description: #{result1.error_description}."
else
	puts "land of no return"
end


#tools like chef or puppet