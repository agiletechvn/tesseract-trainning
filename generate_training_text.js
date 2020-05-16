const fs = require('fs');
const yargs = require('yargs');
const dayjs = require('dayjs');

const argv = yargs
  .option('type', {
    alias: 't',
    description: 'Type of data',
    type: 'string',
  })
  .option('output', {
    alias: 'o',
    description: 'Ouput file',
    type: 'string',
  })
  .help()
  .alias('help', 'h').argv;

const actions = {
  date(filename) {
    // 10 - 80

    const b = dayjs().subtract(10, 'year');
    let a = b.subtract(80, 'year');

    var file = fs.createWriteStream(filename);
    file.on('error', function (err) {
      /* error handling */
      console.error(err);
    });

    for (; a.isBefore(b); a = a.add(1, 'day')) {
      file.write(a.format('DD/MM/YYYY'));
      file.write('\n');
    }
    file.end();
  },
  idcard(filename) {
    var list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

    var getPermutations = function (list, maxLen) {
      // Copy initial values as arrays
      var perm = list.map(function (val) {
        return [val];
      });
      // Our permutation generator
      var generate = function (perm, maxLen, currLen) {
        // Reached desired length
        if (currLen === maxLen) {
          return perm;
        }
        // For each existing permutation
        for (var i = 0, len = perm.length; i < len; i++) {
          var currPerm = perm.shift();
          // Create new permutation
          for (var k = 0; k < list.length; k++) {
            perm.push(currPerm.concat(list[k]));
          }
        }
        // Recurse
        return generate(perm, maxLen, currLen + 1);
      };
      // Start with size 1 because of initial values
      return generate(perm, maxLen, 1);
    };
    var num = parseInt(process.argv[2]) || 4;
    var arr = getPermutations(list, num);

    var file = fs.createWriteStream(filename);
    file.on('error', function (err) {
      /* error handling */
      console.error(err);
    });
    arr.forEach(function (v) {
      file.write(v.join(''));
      file.write('\n');
    });
    file.end();
  },
};

// trigger
actions[argv.type](argv.output);
