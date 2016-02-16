# require 'open-uri'
require 'pry'
require 'mimemagic'
require 'exifr'
require 'mini_magick'
require 'date'

class Event < ActiveRecord::Base
	belongs_to :user
	has_many :invitees
	has_many :event_photos
	has_one  :main_image

	#validates :url, presence: true 
	attr_accessor :photo
	#what is attr_accessor doing here and how does it work with the strong params?

	def initialize(params = nil, photo = nil)
		@photo = photo
		super(params)
	end

	def user
		User.find(self.user_id)
	end

	def date
		self.time_at.strftime('%A %d, %Y')
	end

	def time
		self.time_at.strftime('%-I%p')
	end


	validate do 
		if !@photo.present? && (!self.latitude && !self.longitude)
			errors.add(:photo)
		elsif !self.title.present?
			errors.add(:title)
		elsif !self.time_at.present?
			errors.add(:time_at)
		else
			if @photo.present?
				@format = MimeMagic.by_magic(File.open(@photo.tempfile)).subtype
				@photo_data = EXIFR::JPEG.new(@photo.path).exif
				#pass type to after save to add to file before local storage
				if @format != 'jpeg'
					errors.add(:photo)
				elsif !@photo_data
					errors.add(:photo)
				end
			end
		end
	end

	def image_url
		"/photos/#{self.id.to_s}.jpeg"
	end

	def owner?(current_user)
		user.id == current_user.id 
	end

	def url
		"#{ENV['EXTERNAL_URL']}/events/#{self.id}"
	end

	after_save do
		if @photo
      #read about fileutils functionality
      # Open the tempfile using MiniMagick     (File -> Open)
			image = MiniMagick::Image.open(@photo.path)
			# perform any mini_magick operations
			image.auto_orient
			# write out the final product  (File -> Save)
			image.write("public/photos/#{self.id}." + @format)
	    # FileUtils.cp(@photo.path, "public/photos/#{id}." + @format)

			new_image = MainImage.new(url: self.id.to_s + '.' + @format, format: @format)
			new_image.save()	
		end
	end

end
