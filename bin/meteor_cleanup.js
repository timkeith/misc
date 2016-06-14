#!/usr/bin/env node

var exit = require('exit');
var path = require('path');
var jf = require('jsonfile')
var util = require('util')
var each = require('dir-each');
var series = require('dir-each/series');
var argv = require('minimist')(process.argv.slice(2));
var files = [];
var METEOR = process.env.HOME+'/.meteor';
// console.log(process.env)
var verbose = 'v' in argv;

if('h' in argv)
{
	console.log(process.env['_']+' [-h -v -p] [release]');
	console.log('show all meteor releases installed, or a specific release');
	console.log('-h this help message');
	console.log('-p show packages');
	console.log('-v verbose');
	exit(0);
}
each(METEOR+'/releases', function(path){
	// console.log(path)
	if(path.match(/release.json$/)) files.push(path);
}).read(function(){
	if(verbose)
		console.log('there are %d versions installed', files.length);
	files.forEach(function(file) {
		jf.readFile(file, function(err,obj) {
			var version = path.basename(file).split(/\./);version.pop();version.pop(); version = version.join('.');
			if(argv['_'].length<=0 || argv['_'][0] == version)
			{
				console.log('# '+version);
				if('p' in argv)
				{
					if(err) console.log(err);
					else
					{
						console.log('rm -rf '+METEOR+'/tools/'+obj.tools);
						if(obj.packages)
							for(var p in obj.packages)
							{
								if(verbose) console.log('# '+p);
								console.log('rm -rf '+METEOR+'/packages/'+obj.packages[p]);
							}
					} 
				}
				else console.log('rm -rf '+METEOR+'/tools/'+obj.tools);
			}
		})
	})
});
