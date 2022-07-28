//
//  ADHDefine.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/29.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

@class ADHSession;

#ifndef ADHDefine_h
#define ADHDefine_h

typedef void (^ADHProtocolSessionProgress)(ADHSession * session);
typedef void (^ADHProtocolSessionSuccess)(ADHSession * session);
typedef void (^ADHProtocolSessionFailed)(ADHSession * session);

#endif /* ADHDefine_h */
