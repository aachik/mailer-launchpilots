require 'sinatra'
require 'csv'
require 'pony'

Pony.options = {
  via: :smtp,
  via_options: {
    address:              'smtp.gmail.com',
    port:                  '587',
    enable_starttls_auto:  true,
    user_name:             'theabsbot@gmail.com',
    password:              'a01231261',
    authentication:       :plain, 
    domain:               "pyheart.com" 
  }
}

get '/' do
 erb :new_mass_email
end

post '/mass_emails' do
	number_of_ab_tests = params[:from].count
	opts = {headers: true, converters: :all,
	        header_converters: lambda {|h| h.downcase unless h.nil?}}
	headers = CSV.read(params[:file][:tempfile].path, opts).headers
	CSV.foreach(params[:file][:tempfile].path, opts) do |row|
	  ab_test_index = ($INPUT_LINE_NUMBER % number_of_ab_tests)
	  Pony.mail(
	  	:to => row["email"].to_s, 
	  	:from => params[:from][ab_test_index.to_s], 
	  	:subject => params[:subject][ab_test_index.to_s],
	  	:headers => headers,
	  	:body => params[:template][ab_test_index.to_s],
	  	:attachments => row.to_hash
	  	)
	redirect '/'
	end
end
