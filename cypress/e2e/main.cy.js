describe('template spec', () => {

  it('Visits main page, sign up and log in', () => {
    cy.visit('http://localhost:4567/')
    cy.contains('Log In').click()

    //Registers a new user
    cy.contains('Sign up').click()
    cy.get('input[name=username]').type("Username", {force: true})
    cy.get('input[name=password1]').type("Password", {force: true})
    cy.get('input[name=password2]').type("Password", {force: true})
    cy.get('input[name=profileImage]').type("https://cdn.discordapp.com/attachments/935878618104627252/1065628039398047794/IMG_0108.jpg")
    cy.get('input[type="submit"]').click()
    

    //Log in
    cy.get('input[name=username]').type("Username", {force: true})
    cy.get('input[name=password]').type("Password", {force: true})
    cy.get('input[type=submit]').click()

    //Create, edit, delete comment
    cy.contains('Games').click()
    cy.contains('PLAY').click()
    cy.get('input[name=content]').type("Very bad game! >:(", {force: true})
    cy.contains('Post comment').click()
    cy.get('input[value="Edit"]').first().click({force: true})
    cy.get('input[name=content]').clear().type("Very good game! <:)", {force: true})
    cy.get('input[type=submit]').click()
    cy.get('input[value="Delete"]').first().click({force: true})

    //Edit profile
    cy.get('.topnav-user').click()
    cy.get('input[name=username]').clear({force: true}).type("Usernaaame", {force: true})
    cy.get('input[name=password1]').clear({force: true}).type("Password", {force: true})
    cy.get('input[name=password2]').clear({force: true}).type("Passwooord", {force: true})
    cy.get('input[name=password3]').clear({force: true}).type("Passwooord", {force: true})
    cy.get('input[name=profileImage]').clear({force: true}).type("https://cdn.discordapp.com/attachments/911749805473153074/1075159056240615494/DALLE_2023-02-14_21.png")
    cy.get('input[value="Edit profile"]').click()

    cy.get('input[name=username]').clear({force: true}).type("Username", {force: true})
    cy.get('input[name=password1]').clear({force: true}).type("Passwooord", {force: true})
    cy.get('input[name=password2]').clear({force: true}).type("Password", {force: true})
    cy.get('input[name=password3]').clear({force: true}).type("Password", {force: true})
    cy.get('input[name=profileImage]').clear().type("https://cdn.discordapp.com/attachments/935878618104627252/1065628039398047794/IMG_0108.jpg")
    cy.get('input[value="Edit profile"]').click()

    //Logout
    cy.get('input[value="Log out"]').click()

    //Log in as Admin
    cy.contains('Log In').click()
    cy.get('input[name=username]').type("Admin", {force: true})
    cy.get('input[name=password]').type("password", {force: true})
    cy.get('input[type=submit]').click()

    //Create, edit, delete game
    cy.contains('Games').click()
    cy.get('article.gameitem.addgameitem').click()
    cy.contains('EDIT').first().click({force: true})
    cy.get('input[name=title]').clear({force: true}).type("Very good game", {force: true})
    cy.contains('Update Game').click()
    cy.contains('EDIT').first().click({force: true})
    cy.get('input[value="Delete Game"]').first().click({force: true})
  })
})