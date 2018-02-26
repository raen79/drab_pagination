"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Pagination = exports.Pagination = function () {
  function Pagination(drab, fetchNextEntriesFuncName) {
    _classCallCheck(this, Pagination);

    this._drab = drab;
    this._fetchNextEntriesFuncName = fetchNextEntriesFuncName;
    this._isDrabQueried = false;
    this.bindEvents();
  }

  _createClass(Pagination, [{
    key: "bindEvents",
    value: function bindEvents() {
      self = this;

      window.setTimeout(function () {
        self._loadNewEntries();
      }, 200);

      $(window).scroll(function () {
        self._loadNewEntries();
      });
    }
  }, {
    key: "unbindEvents",
    value: function unbindEvents() {
      $(window).unbind("scroll");
    }
  }, {
    key: "drabResponded",
    value: function drabResponded() {
      this._isDrabQueried = false;
    }
  }, {
    key: "setDrabAsQueried",
    value: function setDrabAsQueried() {
      self = this;
      this._isDrabQueried = true;

      window.setTimeout(function () {
        self._isDrabQueried = false;
      }, 500);
    }
  }, {
    key: "_loadNewEntries",
    value: function _loadNewEntries() {
      if (this._isUserBelowBottom() && this._isDrabQueried == false) {
        this._drab.exec_elixir(this._fetchNextEntriesFuncName, {});
        this.setDrabAsQueried();
      }
    }
  }, {
    key: "_isUserBelowBottom",
    value: function _isUserBelowBottom() {
      return $(window).scrollTop() + $(window).height() > this._lastEntryPosition();
    }
  }, {
    key: "_lastEntryPosition",
    value: function _lastEntryPosition() {
      return $(".paginate").last().position().top;
    }
  }]);

  return Pagination;
}();