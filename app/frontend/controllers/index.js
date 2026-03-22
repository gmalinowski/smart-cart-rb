// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application.js"

import HelloController from "./hello_controller.js"
application.register("hello", HelloController)

import Dropdown from '@stimulus-components/dropdown'
application.register('dropdown', Dropdown)

import Flash from './flash_controller.js'
application.register('flash', Flash)

import FlashBridge from './flash_bridge_controller.js'
application.register('flash-bridge', FlashBridge)
