ApiLogger = LogStashLogger.new(type: :file, path: 'log/api.log', sync: true)
AdhocWorkerLogger = LogStashLogger.new(type: :file, path: 'log/adhoc-worker.log', sync: true)
ServiceItemImportLogger = LogStashLogger.new(type: :file, path: 'log/service-item-import.log', sync: true)