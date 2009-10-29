use Module::Build;

Module::Build->new
    ( module_name     => 'PerlIO::via::gzip',
      license         => 'perl',
      requires        => {
	                 perl                  => 5.010,
			 'IO::Compress::Gzip'  => 2,
			 'IO::Uncompress::Gunzip'  => 2,
			 'PerlIO::Util'        => 0
                         },
      build_requires  => {
	                 'Module::Build'       => 0,
                         'Test::More'          => 0,
                         },
      create_makefile_pl     => 'passthrough'
      
    )->create_build_script;
