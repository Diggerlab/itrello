refreshBoards = ->
  for bid in window.boards
    if $('#board_'+ bid)[0]
      console.log 'refreshing board #'+ bid
      render_actions(bid, $('#board_'+ bid).find('.actions'), true)


render_actions = (bid, parentEle, newer) ->
  console.log 'render actions for #'+ bid
  Trello.get '/boards/' + bid  + '/actions', {}, (actions) ->
    ac = $('<div></div>')
    for action in actions
      if action.data.card?
        # console.log action
        user = action.memberCreator.fullName
        content = action.data.text
        content = action.data.card.name unless content?
        date = new Date(action.date)
        time = date.format('n-j H:i')
        timestamp = date.format('YmdHisu')
        type = action.type
        card_id = action.data.card.id

        if (newer && (timestamp > window.refreshTime)) || !newer
          ac.append '<hr>'
          ac.append '<p>'
          ac.append '<span class="new"> &nbsp; </span>' if timestamp > window.refreshTime
          ac.append '<span class="user">' + user + ': </span>'
          ac.append '<span>'+ content + '</span>'
          ac.append '<span class="timestamp">'+ time + '</span>'
          ac.append '<span class="label type"><a href="https://trello.com/card/'+ bid + '/' + card_id + '" target="_blank">' + type + '</a></span>'
          ac.append '</p>'
          window.refreshTime = timestamp if newer
            

    parentEle.prepend ac

render_board = (board) -> 
  return false if board.name != 'Bernard' && board.name != 'Project P'
  $('.loading').show()
  board_id = board.id
  console.time board_id 
  $('#board_'+ board_id ).remove()
  new_board_container = $('<div id="board_'+board_id+'" class="six columns board"></div>')
  new_board = $('<div class="panel"/>')
  new_name = $('<h4></h4>')
  new_name.append board.name
  new_board.append new_name
  new_actions = $('<div class="actions"></div>')
  render_actions board_id, new_actions, false
  new_board.append new_actions
  new_board_container.append new_board
  $('.boards').append new_board_container
  $('.loading').hide()
  console.timeEnd board_id

loadBoards = -> 
  now = new Date()
  window.refreshTime = now.format('YmdHisu')
  for bid in window.boards
    console.log 'loading board #'+ bid
    Trello.boards.get bid, (b) -> 
      render_board b if !b.closed
    , (e) -> 
        console.log 'error when load board ' + e

onAuthorized = -> 
  Trello.get '/members/me', {}, 
  (u) ->
    window.user = u
    window.boards = u.idBoards.sort()
    loadBoards()
    setInterval(refreshBoards, 60000)

  , (e) -> 
    console.log 'error when authorize' + e


# start loading data..
window.user = null
window.refreshTime = null
window.boards = []

opt = 
  name: "iTrello"
  success: -> onAuthorized()

console.time 't'

if !Trello.authorized()
  return Trello.authorize(opt)
else
  onAuthorized()

