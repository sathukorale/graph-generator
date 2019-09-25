const express = require('express');
const app = express();
const exec = require('child_process').exec;
const fs = require('fs');
const util = require('util');
const writeFileAsync = util.promisify(fs.writeFile);
const unlinkFileAsync = util.promisify(fs.unlink);
const crypto = require('crypto');
const path = require('path');

const appLocation = path.dirname(require.main.filename);
const appDataDirectory = path.join(appLocation, "data");
const appResourcesDirectory = path.join(appLocation, "resources")
const appTmpDataDirectory = path.join(appDataDirectory, "tmp");

const dependenciesJsFile = path.join(appLocation, "dependencies.js");
if (! fs.existsSync(dependenciesJsFile)) throw "Looks like the GraphGenerator server isn't setup properly. Please run the 'setup.sh' script to do the initial setup.";

const dependencies = require(dependenciesJsFile);

const plantUmlJarLocation = dependencies.plantumlBinary;
const dotBinaryLocation = dependencies.graphvizBinary;
const asciiDoctorLocation = "/usr/local/rvm/gems/ruby-2.6.3/bin/asciidoctor";
const mermaidBinaryLocation = dependencies.mermaidBinary;
const ditaaJarLocation = dependencies.ditaaBinary;
const diagtoolLocations = dependencies.blockdiagTools;

const defaultPage = path.join(appResourcesDirectory, "default.html");
const puppeteerConfigLocation = path.join(appResourcesDirectory, "puppeteer-config.json");

const scriptContentRecordsFilePath = path.join(appDataDirectory, "contentrequests.recordfile");

const stashAccessibleUserName = "mmd_ciuser";
const stashAccessibleUserPasswd = "mit@12345";
const stashAccessibleUser = stashAccessibleUserName + ":" + stashAccessibleUserPasswd;
const serverPort = 3001;

const formatsSupportedByRegularMeans = [ "plantuml", "dot", "graphviz", "mermaid", "ditaa", "actdiag", "nwdiag", "blockdiag", "seqdiag", "packetdiag", "rackdiag" ]
const formatsSupportedByAsciiDctor = [ "erd", "msc", "shaape", "syntrax", "umlet", "vega", "vegalite", "wavedrom" ];

app.get('/', onShowDefaultPageRequest);
app.get('/generate-graph', onGenerateGraphRequest);
app.get('/get-supported-graphs', onGetSupportedGraphList);

app.listen(serverPort, () => 
{
	dependencies.PrintDependencyLocations()
	console.log();
	console.log(" >> GraphGenerator starting on port, " + serverPort + "...");
});

function IsSupportedByAsciiDoctor(contentType)
{
	return (formatsSupportedByAsciiDctor.indexOf(contentType) != -1);
}

function IsSupportedByRegularMethods(contentType)
{
	return (formatsSupportedByRegularMeans.indexOf(contentType) != -1);
}

function IsSupportedByTheScript(contentType)
{
	return (IsSupportedByAsciiDoctor(contentType) || IsSupportedByRegularMethods(contentType));
}

function onShowDefaultPageRequest(request, response)
{
	var ip = request.headers['x-forwarded-for'] || request.connection.remoteAddress;
	console.log(" >> Default page request. Replying back with the default page. (RemoteEndpoint='" + ip + "')");

	response.sendFile(defaultPage);
}

function onGetSupportedGraphList(request, response)
{
	var content = "";
	for (var i in formatsSupportedByRegularMeans) content += ((content.length > 0 ? ";" : "") + formatsSupportedByRegularMeans[i]);
	
	response.status(200);
	response.send(content);

	console.log(" >> Supported graph list requested. Replying back with the list. (SupportedGraphList='" + content + "')");
}

function onGenerateGraphRequestWithFile(request, response)
{
	var location = decodeURIComponent(request.query.location);
	var accessMethod = request.query.accessMethod.trim();
	var contentType = request.query.contentType.trim();

	if (accessMethod != "http" && accessMethod != "git")
	{
		console.log(" >> The value supplied for the parameter 'accessMethod' is invalid. Ignoring the request.");

		response.status(400);
		response.send("Invalid parameter. (accessMethod=REQUIRED [http|git]");
		return;
	}

	if (IsSupportedByTheScript(contentType) == false)
	{
		console.log(" >> The value supplied for the parameter 'contentType' is invalid. Ignoring the request.");

		response.status(400);
		response.send("Invalid parameter. (contentType=REQUIRED [plantuml|dot])");
		return;
	}

	var generator = new GraphGenerator(response);
	generator.GenerateWithLocation(location, accessMethod, contentType);
}

function onGenerateGraphRequestWithContent(request, response)
{
	var isEncoded = request.query.isEncoded ? true : false;
	var scriptContent = isEncoded ? (Buffer.from(decodeURIComponent(request.query.scriptContent), 'base64').toString('utf-8')) : request.query.scriptContent;
	var contentType = request.query.contentType;

	if (IsSupportedByTheScript(contentType) == false)
	{
		console.log(" >> The value supplied for the parameter 'contentType' is invalid. Ignoring the request.");

		response.status(400);
		response.send("Invalid parameter. (contentType=REQUIRED [plantuml|dot])");
		return;
	}

	var generator = new GraphGenerator(response);
	generator.GenerateWithContent(scriptContent, contentType);
}

function onGenerateGraphRequest(request, response)
{
	var ip = request.headers['x-forwarded-for'] || request.connection.remoteAddress;
	var location = request.query.location;
	var accessMethod = request.query.accessMethod;
	var contentType = request.query.contentType;
	var scriptContent = request.query.scriptContent;

	console.log(" >> A graph-generation request was made with the following parameters (location='" + location + "', accessMethod='" + accessMethod + "', contentType='" + contentType + "', scriptContent='" + scriptContent + "', RemoteEndpoint='" + ip + "')");

	if (location && accessMethod && contentType)
	{
		onGenerateGraphRequestWithFile(request, response);
	}
	else if (scriptContent && contentType)
	{
		onGenerateGraphRequestWithContent(request, response);
	}
	else
	{
		console.log(" >> The graph-generation request was missing some parameters. Ignoring the request.");

		response.status(400);
		response.send("Missing parameter(s). (location or scriptContent=REQURED, accessMethod=REQUIRED if 'location' is set [http|git], contentType=REQUIRED [plantuml|dot])");
		return;
	}
}

function CheckAndCreateApplicationDirectories()
{
	if (fs.existsSync(appDataDirectory) == false) fs.mkdirSync(appDataDirectory);
	if (fs.existsSync(appTmpDataDirectory) == false) fs.mkdirSync(appTmpDataDirectory);
}

function GetTimeInNanoseconds()
{
	const time = process.hrtime();
	return (time[0] * 1000000000) + time[1];
}

function GetFileSize(filePath)
{
	try
	{		
		let stats = fs.statSync(filePath)
		return stats.size;
	}
	catch (ex) { }

	return 0;
}

function GraphGenerator(response)
{
	this._response = response;
	this._grapContent = null;
	this._scriptLocation = null;
	this._scriptContent = null;
	this._accessType = null;
	this._contentType = null
	this._inputFileLocation = null;
	this._outputFileLocation = null;
	var self = this;

	var DownloadScript = function(location, accessType)
	{
		console.log(" >> Downloading the content of the file at '" + location + "'.");

		try
		{
			var command = "curl --insecure --fail -sS " + location; // + " --user " +  stashAccessibleUser;
			exec(command, OnScriptDownloaded);
		}
		catch (ex) 
		{
			console.log(" >> The curl command failed abruptly. Most likely the script location was invalid. (Reason=" + ex + ")");
		}
	};

	var OnScriptDownloaded = function(err, stdout, stderr)
	{
		if (stdout.trim().length == 0)
		{
			console.log(" >> Couldn't download the file at, '" + self._scriptLocation + "'. (Reason='" + stderr.trim() + "')");

			response.status(400);
			response.send("Couldn't download file at '" + self._scriptLocation + "'. (Reason='" + stderr.trim() + "')");
			return;
		}

		var scriptContent = stdout.trim();

		console.log(" >> Checking whether an already generated graph exists for these details. (Url=" + self._scriptLocation + ")");

		var uniqueName = GetTimeInNanoseconds();
		var inputFileName = path.join(appTmpDataDirectory, uniqueName + "_input.script");
		var outputFileName = path.join(appDataDirectory, uniqueName + "_output.png");

		var updatedScriptContent = scriptContent;
		if (IsSupportedByAsciiDoctor(self._contentType))
		{
			updatedScriptContent =  "[" + self._contentType + ", " + uniqueName + "_output, png]\n"
			updatedScriptContent += "....\n"
			updatedScriptContent += scriptContent + "\n"
			updatedScriptContent += "...."
		}

		writeFileAsync(inputFileName, updatedScriptContent).catch(error => {});

		var shasum = crypto.createHash('sha1');

		shasum.update(scriptContent);
		var checksum = shasum.digest("hex");

		shasum = crypto.createHash('sha1')
		shasum.update(Buffer.from(self._scriptLocation, 'utf8'));
		var checksumOfLocation = shasum.digest("hex");

		var recordFile = path.join(appDataDirectory, self._contentType + "_" + checksumOfLocation.toString().replace("+", "_").replace("/", "-") + ".recordfile");

		if (fs.existsSync(recordFile))
		{
			console.log(" >> A record file matching the received url was found. (Url=" + self._scriptLocation + ")");

			var segments = fs.readFileSync(recordFile, 'utf8').trim().split("=");
			if (segments.length == 2 && segments[0].trim() == checksum)
			{
				var imageFile = segments[1].trim();
				if (fs.existsSync(imageFile))
				{
					if (GetFileSize(imageFile) > 0)
					{
						console.log(" >> Already existing image file found for the script at '" + self._scriptLocation + "'. (Url=" + self._scriptLocation + ")");
	
						self._response.status(200);
						self._response.sendFile(imageFile);
						return;
					}
					else
					{
						console.log(" >> Even though a record file matching the url, '" + self._scriptLocation + "' exists, the corresponding record points to an invalid file. (Url=" + self._scriptLocation + ")");
					}
				}
				else
				{
					console.log(" >> Even though a record file matching the url, '" + self._scriptLocation + "' exists, the corresponding record points to an absent file. (Url=" + self._scriptLocation + ")");
				}
			}
			else
			{
				if (segments.length == 2)
				{
					console.log(" >> Even though a record file matching the url, '" + self._scriptLocation + "' exists, the current checksum doesn't match the previous. (Url=" + self._scriptLocation + ")");
				}
				else
				{
					console.log(" >> Even though a record file matching the url, '" + self._scriptLocation + "' exists, the record within it was invalid. (Url=" + self._scriptLocation + ")");
				}
			}

			unlinkFileAsync(recordFile);
		}

		writeFileAsync(recordFile, checksum + "=" + outputFileName);
		GenerateGraph(inputFileName, outputFileName, self._contentType);
	};	

	var GenerateGraph = function(inputFileName, outputFileName, contentType)
	{
		console.log(" >> Using the " + contentType + " plugin to generate a graph. (Url=" + self._scriptLocation + ")");
		
		self._inputFileLocation = inputFileName;
		self._outputFileLocation = outputFileName;

		if (contentType == "plantuml")
		{
			if (fs.existsSync(plantUmlJarLocation) == false)
			{
				console.log(" >> The required PlantUML plugin was not found at, '" + plantUmlJarLocation + "'. This is indicative of a server-side error.");

				self._response.status(500);
				self._response.send("Couldn't locate the required plantuml plugin.");
				return;
			}

			exec("cat " + inputFileName + " | java -jar " + plantUmlJarLocation + " -DPLANTUML_LIMIT_SIZE=16384 -pipe > " + outputFileName, OnGraphGenerated);
		}
		else if (contentType == "dot" || contentType == "graphviz")
		{
			exec(dotBinaryLocation + " -Tpng " + inputFileName + " -o " + outputFileName, OnGraphGenerated);
		}
		else if (contentType == "mermaid")
		{
			if (fs.existsSync(mermaidBinaryLocation) == false)
            {
				console.log(" >> The required 'mmdc' (Mermaid Cli) binary was not found at, '" + mermaidBinaryLocation + "'. This is indicative of a server-side error.");
				
				self._response.status(500);
				self._response.send("Couldn't locate the required 'mmdc' binary.");
				return;
            }

			exec(mermaidBinaryLocation + " --puppeteerConfigFile=" + puppeteerConfigLocation + " --input " + inputFileName + " --output " + outputFileName, OnGraphGenerated);
		}
		else if (contentType == "ditaa")
		{
			if (fs.existsSync(ditaaJarLocation) == false)
			{
				console.log(" >> The required 'ditaa.jar' binary was not found at, '" + ditaaJarLocation + "'. This is indicative of a server-side error.");
				
				self._response.status(500);
				self._response.send("Couldn't locate the required 'ditaa.jar' binary.");
				return;
			}

			exec("java -jar " + ditaaJarLocation + " " + inputFileName + " " + outputFileName, OnGraphGenerated);
		}
		else if (contentType in diagtoolLocations)
		{
			var toolName = contentType;
			var toolLocation = diagtoolLocations[toolName];

			if (fs.existsSync(toolLocation) == false)
			{
			    console.log(" >> The required '" + toolName + "' binary was not found at, '" + toolLocation + "'. This is indicative of a server-side error.");
			
			    self._response.status(500);
			    self._response.send("Couldn't locate the required '" + toolName + "' binary.");
			    return;
			}

			exec(toolLocation + " \"" + inputFileName + "\" -o \"" + outputFileName + "\"", OnGraphGenerated);
		}
		else if (IsSupportedByAsciiDoctor(contentType))
		{
			if (fs.existsSync(asciiDoctorLocation) == false)
			{
				console.log(" >> The required 'asciidoctor' binary was not found at, '" + asciiDoctorLocation + "'. This is indicative of a server-side error.");

                self._response.status(500);
                self._response.send("Couldn't locate the required asciidoctor binary.");
                return;
			}
		
			exec(asciiDoctorLocation + " -r asciidoctor-diagram \"" + inputFileName + "\" --destination-dir=" + appDataDirectory, OnGraphGenerated);
		}
	}

	var OnGraphGenerated = function(error, stdout, stderr)
	{
		console.log("stdout=" + stdout);
		console.log("stderr=" + stderr);
		console.log(" >> The " + self._contentType + " binary has processed the received content. Checking whether the expected output is available.");

		try
		{
			unlinkFileAsync(self._inputFileLocation);
		}
		catch (ex) 
		{
			console.log(" >> Failed to delete the downloaded script file at, '" + self._inputFileLocation + "'. (Reason='" + ex + "')");
		}

		if (fs.existsSync(self._outputFileLocation))
		{
			console.log(" >> The expected output image file was found. Replying back with this file.");

			self._response.status(200);
			self._response.sendFile(self._outputFileLocation);
		}
		else
		{
			console.log(" >> The expected output image file ('" + self._outputFileLocation + "') was not found. This is indicative of a server-side error. Replying back with the relevant details.");

			self._response.status(500);
			self._response.send("The " + self._contentType + " binary has failed to generate the output image file.");
		}
	};
	
	this.GenerateWithLocation = function(location, accessType, contentType)
	{
		CheckAndCreateApplicationDirectories();

		self._scriptLocation = location;
		self._accessType = accessType;
		self._contentType = contentType;

		DownloadScript(location, accessType);
	};

	this.GenerateWithContent = function(scriptContent, contentType)
	{
		CheckAndCreateApplicationDirectories();

		self._scriptContent = scriptContent;
		self._contentType = contentType;

		var shasum = crypto.createHash('sha1');
		shasum.update(scriptContent);

		var checksum = contentType + "_" + shasum.digest("hex");
		var uniqueName = GetTimeInNanoseconds();
		var inputFileName = path.join(appTmpDataDirectory, uniqueName + "_input.script");
		var outputFileName = path.join(appDataDirectory, uniqueName + "_output.png");

		console.log(" >> Checking whether a generated graph exists for the same details. (ContentHash='" + checksum + "')");
		
		var existingGraphLocation = null;

		if (fs.existsSync(scriptContentRecordsFilePath))
		{
			var lines = fs.readFileSync(scriptContentRecordsFilePath, 'utf8').trim().split("\n").reverse();
			for (var index in lines)
			{
				var line = lines[index].trim();
				var segments = line.split('=');
	
				if (segments.length == 0) continue;
				if (segments[0] != checksum) continue;
	
				existingGraphLocation = segments[1];
				break;
			}
		}

		if (existingGraphLocation != null)
		{
			console.log(" >> A record matching the current request was found. (ContentHash='" + checksum + "')");

			if (fs.existsSync(existingGraphLocation))
			{
				if (GetFileSize(existingGraphLocation) > 0)
				{
					console.log(" >> The file matching the found record and received request was found. Replying back with this file. (ContentHash='" + checksum +"')");
	
					self._response.sendFile(existingGraphLocation);
					return;
				}
				else
				{
					console.log(" >> Even though a record file matching the url, '" + self._scriptLocation + "' exists, the corresponding record points to an invalid file. (Url=" + self._scriptLocation + ")");
				}
			}
			else
			{
				console.log(" >> Even though a record matching the current request was found, the corresponding file this record points to, doesn't exist.");
			}
		}
		else
		{
			console.log(" >> The server couldn't find any record matching the request details. (ContentHash='" + checksum + "')");
		}

		var updatedScriptContent = scriptContent;
                if (IsSupportedByAsciiDoctor(self._contentType))
                {
                        updatedScriptContent =  "[" + self._contentType + ", " + uniqueName + "_output, png]\n"
                        updatedScriptContent += "....\n"
                        updatedScriptContent += scriptContent + "\n"
                        updatedScriptContent += "...."
                }

		writeFileAsync(inputFileName, updatedScriptContent).catch(error => {});
		
		fs.appendFileSync(scriptContentRecordsFilePath, checksum + "=" + outputFileName + "\n");
		GenerateGraph(inputFileName, outputFileName, self._contentType);	
	};
}