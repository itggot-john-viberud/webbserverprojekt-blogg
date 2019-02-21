require 'slim'
require 'sinatra'
require 'SQLite3'
require 'bcrypt'
require 'byebug'
enable :sessions

get("/") do
    slim(:index)
end

post("/login") do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    result = db.execute("SELECT Username, Password, Authority FROM db WHERE Username = '#{params["Username"]}'")
    if BCrypt::Password.new(result[0]["Password"]) == params["Password"]
       session[:User] = params["Username"]
    else
        login == false
    end
    slim(:index, locals:{
        index: result
    })
    redirect("/")
end

post("/logout") do
    session.destroy
    redirect("/")
end

get("/failed") do
    if login == false
        slim(:failed)
    end
end

post("/create") do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    new_name = params["Username"]
    new_password = params["Password1"]
    
    if params["Password1"] == params["Password2"]
        new_password_hash = BCrypt::Password.create(new_password)
        db.execute("INSERT INTO db (Username, Password, Authority) VALUES (?,?,?)", new_name, new_password_hash, 1)
        redirect("/")
    else 
        redirect("/failed")
    end
end 

get("/new") do
    slim(:new)
end

