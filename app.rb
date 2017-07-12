require 'sinatra'
require 'pry'
require 'dotenv/load'
require 'dannysmith_coolpay'

enable :sessions

CON = Coolpay::Connection.new username: ENV['USERNAME'],
                                     api_key: ENV['API_KEY'],
                                     api_endpoint_url: ENV['API_ROOT_URI']

get '/' do
  redirect '/people'
end

# Recipients
get '/people' do
  @people = CON.recipients
  erb :people
end

post '/people' do
  @person = CON.create_recipient name: params[:name]
  if @person
    session[:message] = "Added #{@person.name}!"
    redirect '/people'
  else
    session[:message] = "Something went wrong!"
    @people = CON.recipients
    erb :people
  end
end

# Payments
get '/payments' do
  @payments = CON.payments.reverse
  @people = CON.recipients
  erb :payments
end

post '/payments' do
  @payment = CON.create_payment amount: params[:amount],
                                          recipient_id: params[:recipient],
                                          currency: params[:currency]
  if @payment
    session[:message] = "Payment of #{@payment.amount}#{@payment.currency} made to #{@payment.recipient.name}. Current Status is #{@payment.status}"
    redirect '/payments'
  else
    session[:message] = "Something went wrong!"
    @payments = CON.payments.reverse
    @people = CON.recipients
    erb :payments
  end
end
