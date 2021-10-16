// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//= require_tree .

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import ConfirmWindow from "custom/confirm_window"
import AlertWindow from "custom/alert_window"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

global.Rails = Rails;
global.ConfirmWindow = ConfirmWindow;
global.AlertWindow = AlertWindow;

require("custom/search_through_stocks")
require("custom/sort_last_query_table")
require("custom/close_element")
require("custom/on_load_events")