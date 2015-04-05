class test_file {
   stage { 'test_s1':  before  => Stage['main']; }
   stage { 'test_s2':  before  => Stage['test_s1']; }
   stage { 'test_s3':  before  => Stage['test_s2']; }
   stage { 'test_s4':  before  => Stage['test_s2']; }

   class { 'test_file::s1':
     stage => 'test_s1',
   }

   class { 'test_file::s2':
     stage => 'test_s2',
   }
   
   #class { 'test_file::s3':
   #  stage => 'test_s3',
   #}

   class { 'test_file::s4':
     stage => 'test_s4',
   }
}
