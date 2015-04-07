### https://docs.puppetlabs.com/guides/virtual_resources.html
### using virtual define-based resources 

define basket($name, $arg) {

     file{ "$name":
           ensure  => present,
           content => "$arg",
     }

}

@basket { 'fruit': name => '/tmp/fruit', arg => 'apple' }
@basket { 'berry': name => '/tmp/berry', arg => 'watermelon' }

realize( Basket[fruit], Basket[berry] )
