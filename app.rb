require 'slim'
require 'sinatra'
require 'SQLite3'
require 'bcrypt'
require 'byebug'
enable :sessions

get("/") do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    namn = db.execute("SELECT Username FROM user")
    slim(:index, locals:{
        skapare: namn
    })
end

post("/login") do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    result = db.execute("SELECT Username, Password FROM user WHERE Username = '#{params["Username"]}'")
    if BCrypt::Password.new(result[0]["Password"]) == params["Password"]
       session[:User] = params["Username"]
    else
        login == false
    end
    if session[:User]

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
    slim(:failed)
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
        db.execute("INSERT INTO user (Username, Password, Mail) VALUES (?,?,?)", new_name, new_password_hash, new_mail)
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
    posts = db.execute("SELECT Rubrik, Bild, Text, Id FROM posts WHERE Creator = '#{session[:User]}'")
    session[:Posts] = posts.first
    slim(:blogg, locals:{
        blogg: posts
    })

end
get("/blogg/:username") do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    posts = db.execute("SELECT Rubrik, Bild, Text, Id FROM posts WHERE Creator = '#{params["username"]}'")
    session[:User] = "guest"
    session[:Posts] = posts.first 
    session[:bloggare] = params["username"]
    slim(:blogg, locals:{
        blogg: posts
    })

end
get("/about/:username") do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    bloggare = params["username"]
    result = db.execute("SELECT * FROM om WHERE Creator=?", bloggare)
    slim(:about)       
end

post('/delete/:id') do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    id = params["id"]

    result_new = db.execute("DELETE FROM posts WHERE Id=?", id)

    redirect('/blogg')
end

get("/edit/:id") do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    id = params["id"]
    result = db.execute("SELECT * FROM posts WHERE Id=?", id)
    who_is_it = db.execute("SELECT Creator FROM posts WHERE Id = ?", id)
    if who_is_it.first[0] == session[:User]
        slim(:edit, locals:{
            posts: result.first})
    else
        redirect('/failed')
    end        
end

post('/edit_execute/:id') do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    new_rubrik = params["Rubrik"]
    new_bild = params["Bild"]
    new_text = params["Text"]
    id = params["id"]
    if new_bild.length == 0
        new_bild = " "
    end
    who_is_it = db.execute("SELECT Creator FROM posts WHERE Id = ?", id)
    if session[:User] == who_is_it.first[0]
        result_new = db.execute("UPDATE posts
            SET Rubrik = ?, Bild = ?, Text = ?
            WHERE Id = ?",
            new_rubrik, new_bild, new_text, id)
    else
        redirect('/failed')
    end

    redirect('/blogg')
end


post("/new_post") do
    db = SQLite3::Database.new("db/user.db")
    db.results_as_hash = true
    new_rubrik = params["Rubrik"]
    new_bild = params["Bild"]
    new_text = params["Text"]
    creator = session[:User]
    db.execute("INSERT INTO posts (Rubrik, Bild, Text, Creator) VALUES (?,?,?,?)", new_rubrik, new_bild, new_text, creator)
    redirect("/blogg")
end 

get("/create_post") do
    slim(:create_post)
end