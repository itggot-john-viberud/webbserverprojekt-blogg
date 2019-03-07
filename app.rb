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
    result = db.execute("SELECT Username, Password FROM User WHERE Username = '#{params["Username"]}'")
    if BCrypt::Password.new(result[0]["Password"]) == params["Password"]
       session[:User] = params["Username"]
    else
        login == false
    end
    slim(:index, locals:{
        index: result
    })
    redirect("/blogg")
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
get("/new") do
    slim(:new)
end
post("/create") do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    new_name = params["Username"]
    new_password = params["Password1"]
    new_mail = params["Mail"]
    
    if params["Password1"] == params["Password2"]
        new_password_hash = BCrypt::Password.create(new_password)
        db.execute("INSERT INTO User (Username, Password, Mail) VALUES (?,?,?)", new_name, new_password_hash, new_mail)
        redirect("/")
    else 
        redirect("/failed")
    end
end 


get("/blogg") do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
#    user_Id = db.execute("SELECT Id FROM User WHERE Username = '#{session[:User]}'")
#    post_id = db.execute("SELECT PostId FROM User_Posts WHERE UserId = #{user_Id.first["Id"]}")
    posts = db.execute("SELECT Rubrik, Bild, Text, Id FROM Posts WHERE Creator = '#{session[:User]}'")
    session[:Posts] = posts.first
    slim(:blogg, locals:{
        blogg: posts
    })

end

post('/delete/:id') do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    id = params["id"]

    result_new = db.execute("DELETE FROM Posts WHERE Id=?", id)

    redirect('/blogg')
end

post('/edit_execute/:id') do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    new_name = params["name"]
    new_email = params["email"]
    new_tel = params["tel"]
    new_dep = params["department"]
    id = params["EmployeeId"]

    result_new = db.execute("UPDATE posts
        SET Rubrik = '?', Bild = '?', Text = '?', Creator = '?'
        WHERE Id = 'id'",
        new_rubrik, new_bild, new_tel, new_dep, id)

    redirect('/blogg')
end


post("/new_post") do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    new_rubrik = params["Rubrik"]
    new_bild = params["Bild"]
    new_text = params["Text"]
    creator = session[:User]
    db.execute("INSERT INTO Posts (Rubrik, Bild, Text, Creator) VALUES (?,?,?,?)", new_rubrik, new_bild, new_text, creator)
    redirect("/blogg")
end 

get("/create_post") do
    slim(:create_post)
end