export class Pagination {
  constructor(drab, fetchNextEntriesFuncName) {
    this._drab = drab;
    this._fetchNextEntriesFuncName = fetchNextEntriesFuncName;
    this._isDrabQueried = false;
    this.bindEvents();
  }

  bindEvents() {
    self = this;

    window.setTimeout(function() {
      self._loadNewEntries()
    }, 200);

    $(window).scroll(function() {
      self._loadNewEntries();
    });
  }

  unbindEvents() {
    $(window).unbind("scroll");
  }

  drabResponded() {
    this._isDrabQueried = false;
  }

  _loadNewEntries() {
    if (this._isUserBelowBottom() && this._isDrabQueried == false) {
      this._drab.exec_elixir(this._fetchNextEntriesFuncName, {});
      this._isDrabQueried = true;
    }
  }

  _isUserBelowBottom() {
    return $(window).scrollTop() + $(window).height() > this._lastEntryPosition();
  }

  _lastEntryPosition() {
    return $(".paginate").last().position().top;
  }
}
