// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.

import { application } from "./application"

// Register each controller with Stimulus
import controllers from "./**/*_controller.js"
controllers.forEach((controller) => {
  application.register(controller.name, controller.module.default)
})

import { Alert, Dropdown, Modal, Tabs, Popover, Toggle, Slideover } from "tailwindcss-stimulus-components"
application.register('alert', Alert)
application.register('dropdown', Dropdown)
application.register('modal', Modal)
application.register('tabs', Tabs)
application.register('popover', Popover)
application.register('toggle', Toggle)
application.register('slideover', Slideover)

// Stimulus Components
import AutoSubmit from '@stimulus-components/auto-submit'
import Sortable from '@stimulus-components/sortable'
application.register('auto-submit', AutoSubmit)
application.register('sortable', Sortable)

import Flatpickr from 'stimulus-flatpickr'
application.register('flatpickr', Flatpickr)
