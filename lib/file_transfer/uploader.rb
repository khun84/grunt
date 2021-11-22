require 'fog/aws'

class Uploader
  DEFAULT_EXPIRE_SEC = 1.day.to_i

  class << self
    def connection(args = {})
      @connection ||= Fog::Storage.new(
        provider: 'AWS',
        aws_access_key_id: args[:aws_access_key_id] || Settings.s3.access_key_id,
        aws_secret_access_key: Settings.s3.secret_access_key,
        region: Settings.s3.region
      )
    end

    def bucket
      @bucket ||= connection.directories.new(key: Settings.s3.bucket)
    end

    def upload_file(file_path, file_name, prefix = 'store', expired_sec = DEFAULT_EXPIRE_SEC)
      file_key = "#{prefix}/#{file_name}"
      bucket.files.create(
        key: file_key,
        body: File.open(file_path),
        public: false
      )

      bucket.files.get(file_key).url(Time.current.to_i + expired_sec)
    end

    def presigned_file_url(file_name, prefix: 'store', expired_sec: DEFAULT_EXPIRE_SEC)
      expired_sec ||= DEFAULT_EXPIRE_SEC
      file_key = "#{prefix}/#{file_name}"
      bucket.files.get(file_key).url(Time.current.to_i + expired_sec)
    end
  end
end
