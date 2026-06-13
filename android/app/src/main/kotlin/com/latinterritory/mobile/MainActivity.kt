package com.latinterritory.mobile

import com.ryanheise.audioservice.AudioServiceActivity

// audio_service requiere que la Activity provea el engine via
// AudioServicePlugin.getFlutterEngine(). AudioServiceActivity override
// provideFlutterEngine() para hacer exactamente eso, evitando el error
// "wrongEngineDetected" que ocurre cuando provideFlutterEngine() retorna
// un engine distinto al que el plugin espera.
class MainActivity : AudioServiceActivity()
