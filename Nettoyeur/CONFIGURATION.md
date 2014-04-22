### TEMPLATE FILES
seqtrimnext come with some template files where you can configure your cleaning steps:
It is easy to read and customize.
the templates are available at  nettoyeur/templates/ directory
please adjust the database locations in the template files after installation: 

* Path for 454 AB adapters database 
`adapters_ab_db = "/path/to/db/formatted/adapters_ab.fasta" `  

* Path for contaminants database 
`contaminants_db = "/path/to/db/formatted/contaminants.fasta" `  

You can define your own templates using a combination of available plugins: 

```
PluginLinker:
- splits sequences into two inserts when a valid linker is found
(paired-end experiments only) 
 
PluginAbAdapters: 
- removes AB adapters from sequences using a predefined DB or
one provided by the user. 
 
PluginAdapters:
- removes Adapters from sequences using a predefined DB or
one provided by the user. 
 
PluginLowHighSize: 
- removes sequences of very small or very big sizes.
 
PluginIndeterminations: 
- removes indeterminations (N) from the sequence. 
 
PluginLowQuality: 
- eliminates low quality regions from sequences. 

PluginContaminants: 
- removes contaminants from sequences or rejects contaminated
ones. It uses a core database, but it can be expanded with user
provided ones.

etc...
```

 

You can modify any template to fit your workflow. To do this, you only need to copy one
of the templates and edit it with a text editor, or simply modify a used_params.txt file that
was produced by a previous cleaning step: /output_files/use_params.txt

E.g. If you want to disable repetition removal, do this: 

1. Copy the template file you wish to customize and name it params.txt. 
2. Edit params.txt with a text editor 
3. Find a line like this:
 
``` 
remove_clonality = true
 
Replace this line with:
remove_clonality = false 
```
### NOTE:
<br/>
>The only mandatory parameter is the plugin_list one. 
