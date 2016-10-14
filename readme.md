# AnimePahe Request System

	This request system is a web application linked to clients that automate downloading, encoding and uploading of video files. This system was designed to streamline the encoding procedure by easing common tasks, such as downloading, sorting, renaming, queueing, and uploading.

## Under development

	This system is under development, the code is not fully tested and is still under revision.

## Changes to be made

	Move renamed files to folder, send to web interface:
		Web interface to rename filenames:
			Rename multiple files at once with rewrite rule.
		Web interface to verify rename:
			Move files to encode queue.

## Usage

	[Animepahe website](http://animepahe.com) after a user has submitted a request an admin will be notified. An admin will check the source files and define which track the correct subtitle and audio language are, then mark the request as accepted. [Dashboard](http://animepahe.com/dashboard) is used to monitor active requests. Depending on which client was marked to process the request, a manager must check the files renamed correctly before queuing them for encoding. After the encoded files have been uploaded and verfied the request will be marked as completed and user that requested it will be notified.
