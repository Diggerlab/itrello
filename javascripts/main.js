(function() {
  var loadBoards, onAuthorized, opt, refreshBoards, render_actions, render_board;

  refreshBoards = function() {
    var bid, _i, _len, _ref, _results;

    _ref = window.boards;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      bid = _ref[_i];
      if ($('#board_' + bid)[0]) {
        console.log('refreshing board #' + bid);
        _results.push(render_actions(bid, $('#board_' + bid).find('.actions'), true));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  render_actions = function(bid, parentEle, newer) {
    console.log('render actions for #' + bid);
    return Trello.get('/boards/' + bid + '/actions', {}, function(actions) {
      var ac, action, card_id, content, date, time, timestamp, type, user, _i, _len;

      ac = $('<div></div>');
      for (_i = 0, _len = actions.length; _i < _len; _i++) {
        action = actions[_i];
        if (action.data.card != null) {
          user = action.memberCreator.fullName;
          content = action.data.text;
          if (content == null) {
            content = action.data.card.name;
          }
          date = new Date(action.date);
          time = date.format('n-j H:i');
          timestamp = date.format('YmdHisu');
          type = action.type;
          card_id = action.data.card.id;
          if ((newer && (timestamp > window.refreshTime)) || !newer) {
            ac.append('<hr>');
            ac.append('<p>');
            if (timestamp > window.refreshTime) {
              ac.append('<span class="new"> &nbsp; </span>');
            }
            ac.append('<span class="user">' + user + ': </span>');
            ac.append('<span>' + content + '</span>');
            ac.append('<span class="timestamp">' + time + '</span>');
            ac.append('<span class="label type"><a href="https://trello.com/card/' + bid + '/' + card_id + '" target="_blank">' + type + '</a></span>');
            ac.append('</p>');
            if (newer) {
              window.refreshTime = timestamp;
            }
          }
        }
      }
      return parentEle.prepend(ac);
    });
  };

  render_board = function(board) {
    var board_id, new_actions, new_board, new_board_container, new_name;

    if (board.name !== 'Bernard' && board.name !== 'Project P') {
      return false;
    }
    $('.loading').show();
    board_id = board.id;
    console.time(board_id);
    $('#board_' + board_id).remove();
    new_board_container = $('<div id="board_' + board_id + '" class="six columns board"></div>');
    new_board = $('<div class="panel"/>');
    new_name = $('<h4></h4>');
    new_name.append(board.name);
    new_board.append(new_name);
    new_actions = $('<div class="actions"></div>');
    render_actions(board_id, new_actions, false);
    new_board.append(new_actions);
    new_board_container.append(new_board);
    $('.boards').append(new_board_container);
    $('.loading').hide();
    return console.timeEnd(board_id);
  };

  loadBoards = function() {
    var bid, now, _i, _len, _ref, _results;

    now = new Date();
    window.refreshTime = now.format('YmdHisu');
    _ref = window.boards;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      bid = _ref[_i];
      console.log('loading board #' + bid);
      _results.push(Trello.boards.get(bid, function(b) {
        if (!b.closed) {
          return render_board(b);
        }
      }, function(e) {
        return console.log('error when load board ' + e);
      }));
    }
    return _results;
  };

  onAuthorized = function() {
    return Trello.get('/members/me', {}, function(u) {
      window.user = u;
      window.boards = u.idBoards.sort();
      loadBoards();
      return setInterval(refreshBoards, 60000);
    }, function(e) {
      return console.log('error when authorize' + e);
    });
  };

  window.user = null;

  window.refreshTime = null;

  window.boards = [];

  opt = {
    name: "iTrello",
    success: function() {
      return onAuthorized();
    }
  };

  console.time('t');

  if (!Trello.authorized()) {
    return Trello.authorize(opt);
  } else {
    onAuthorized();
  }

}).call(this);
