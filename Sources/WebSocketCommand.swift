//
//  WebSocketCommand.swift
//  X
//
//  Created by huhuegg on 2017/5/2.
//  Copyright © 2017年 jiangchao. All rights reserved.
//

enum WebSocketCommand: Int {
    case test                       = 0
    case reqDeviceAdmin             = 101
    case respDeviceAdmin            = 201
    case pushDeviceAdmin            = 301
    case reqUserAnswerQuestion      = 102
    case respUserAnswerQuestion     = 202
    case pushUserAnswerQuestion     = 302
    case reqUserStatusChange        = 103
    case respUserStatusChange       = 203
    case pushUserStatusChange       = 303
    case reqCoursewareOpen          = 110
    case respCoursewareOpen         = 210
    case pushCoursewareOpen         = 310
    case reqCoursewareClose         = 111
    case respCoursewareClose        = 211
    case pushCoursewareClose        = 311
    case reqCoursewareSizeChange    = 112
    case respCoursewareSizeChange   = 212
    case pushCoursewareSizeChange   = 312
    case reqMessagewSend            = 117
    case respMessageSend            = 217
    case pushMessageSend            = 317
    case reqQuestionCreate          = 118
    case respQuestionCreate         = 218
    case pushQuestionCreate         = 318
    case reqSpecifyStudentAnswerQuestion    = 119
    case respSpecifyStudentAnswerQuestion   = 219
    case pushSpecifyStudentAnswerQuestion   = 319
    case reqAnswerCheck             = 120
    case respAnswerCheck            = 220
    case pushAnswerCheck            = 320
    case reqAnswerSubmit            = 121
    case respAnswerSubmit           = 221
    case pushAnswerSubmit           = 321
    case reqCreditChange            = 122
    case respCreditChange           = 222
    case pushCreditChange           = 322
    case reqPlayMediaSynchronously  = 123
    case respPlayMediaSynchronously = 223
    case pushPlayMediaSynchronously = 323
    case reqMediaReady              = 124
    case respMediaReady             = 224
    case pushMediaReady             = 324
    case reqMediaControl            = 125
    case respMediaControl           = 225
    case pushMediaControl           = 325
    case reqMediaControlStatus      = 126
    case respMediaControlStatus     = 226
    case pushMediaControlStatus     = 326
    case reqOpenFile                = 127
    case respOpenFile               = 227
    case pushOpenFile               = 327
    case reqDocumentControl         = 128
    case respDocumentControl        = 228
    case pushDocumentControl        = 328
//    case 129
//    case 229
//    case 329

}


