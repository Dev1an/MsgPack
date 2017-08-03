//
//  Reference.swift
//  MsgPack
//
//  Created by Damiaan on 3/08/17.
//  Copyright © 2017 dPro. All rights reserved.
//

import Foundation

class Reference<T> {
	var storage: T
	init(to value: T) {
		storage = value
	}
}
