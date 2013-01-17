render_board = (board) -> 
  return false if board.name != 'Bernard' && board.name != 'Project P'
  new_board_container = $('<div class="six columns board"></div>')
  new_board = $('<div class="panel"/>')
  new_name = $('<h4></h4>')
  new_name.append board.name
  new_board.append new_name


  Trello.get '/boards/' + board.id + '/actions', {}, (actions) ->
    for action in actions
      if action.data.card?
        # console.log action
        user = action.memberCreator.fullName
        content = action.data.text
        content = action.data.card.name unless content?
        date = new Date(action.date)
        timestamp = date.format('n-j H:i')
        type = action.type
        board_id = board.id
        card_id = action.data.card.id
        new_board.append '<hr>'
        new_board.append '<p>'
        new_board.append '<span class="user">' + user + ': </span>'
        new_board.append '<span>'+ content + '</span>'
        new_board.append '<span class="timestamp">'+ timestamp + '</span>'
        new_board.append '<span class="label type"><a href="https://trello.com/card/'+ board_id + '/' + card_id + '" target="_blank">' + type + '</a></span>'
        new_board.append '</p>'

  new_board_container.append new_board
  $('.boards').append new_board_container

loadBoards = -> 
  for bid in window.user.idBoards
    Trello.boards.get bid, (b) -> 
      render_board b if !b.closed
    , (e) -> 
        console.log 'error when load board ' + e

onAuthorized = -> 
  Trello.get '/members/me', {}, 
  (u) ->
    window.user = u
    # $('.user').html u.fullName
    loadBoards()
  , (e) -> 
    console.log 'error when authorize' + e


# start loading data..
window.user = null
window.boards = []

opt = 
  name: "iTrello"
  success: -> onAuthorized()

if !Trello.authorized()
  return Trello.authorize(opt)
else
  onAuthorized()

