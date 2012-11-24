# Customize this script to your login, by replacing username and password with your own. 
submitLogin = ->
  jQuery('input#login_username').val('username')
  jQuery('input#login_password').val('password')
  jQuery('form#login').submit()
  return true


page = require('webpage').create();
timestamp = +new Date()


injectjQuery = ->
  page.injectJs './jquery.js'
  page.evaluate ->
    jQuery.noConflict()

doLogin = ->
  page.evaluate submitLogin

displayBalance = ->
  data = page.evaluate ->
    return eval("("+document.body.innerText+")")

  monies = Math.round(data['balances']['safe_to_spend']*1 /10000)
  console.log( "Monies: ", '$'+monies)

page.onLoadFinished = (status) ->
  if status == 'success'
    
    # state is undefined when we first run this script
    if !phantom.loggedIn
      injectjQuery()
      doLogin()
      phantom.loggedIn = true
    else
      displayBalance()
      phantom.exit()
  else
    console.log('Connection failed.')
    phantom.exit()

# console messages send from within page context are ingnored by default
# this puts them back where they belong.
page.onConsoleMessage = (msg) ->
  console.log(msg)


# Need to look like a supported agent in order for login to be accepted
page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.64 Safari/537.4'

page.open('https://simple.com/transactions/new_transactions?timestamp='+timestamp)