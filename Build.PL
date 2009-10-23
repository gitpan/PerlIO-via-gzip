use Module::Build;

Module::Build->new
    ( module_name     => 'PerlIO::via::gzip',
      perl            => 5.10,
      license         => 'perl',
      requires        => {
	                 'Compress::Zlib'      => 2
                         },
      build_requires  => {
	                 'Module::Build'       => 0,
                         'Test::More'          => 0,
			 'IO::Compress::Gzip'  => 2,
			 'IO::Uncompress::Gunzip'  => 2
                         }
      
    )->create_build_script;
