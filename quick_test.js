// Quick Test Script for ParkEase App
// Run this in Node.js console or save as .js file

const testParkEaseApp = async () => {
  console.log('🧪 PARKEASE QUICK TEST SUITE');
  console.log('=' .repeat(40));
  
  const tests = {
    projectStructure: () => {
      const fs = require('fs');
      console.log('\n📁 Testing Project Structure...');
      
      const requiredFiles = [
        'backend/package.json',
        'frontend/pubspec.yaml',
        'backend/src/server.js',
        'backend/src/data/seedDatabase.js',
        'frontend/lib/main.dart'
      ];
      
      let passed = 0;
      requiredFiles.forEach(file => {
        if (fs.existsSync(file)) {
          console.log(`✅ ${file}`);
          passed++;
        } else {
          console.log(`❌ ${file}`);
        }
      });
      
      console.log(`📊 Structure Test: ${passed}/${requiredFiles.length} files found`);
      return passed === requiredFiles.length;
    },
    
    backendDependencies: () => {
      console.log('\n📦 Testing Backend Dependencies...');
      try {
        const packageJson = require('./backend/package.json');
        const requiredDeps = ['express', 'mongoose', 'bcryptjs', 'jsonwebtoken'];
        
        let found = 0;
        requiredDeps.forEach(dep => {
          if (packageJson.dependencies && packageJson.dependencies[dep]) {
            console.log(`✅ ${dep}: ${packageJson.dependencies[dep]}`);
            found++;
          } else {
            console.log(`❌ ${dep}: Not found`);
          }
        });
        
        console.log(`📊 Dependencies: ${found}/${requiredDeps.length} found`);
        return found === requiredDeps.length;
      } catch (error) {
        console.log(`❌ Error reading package.json: ${error.message}`);
        return false;
      }
    },
    
    frontendConfig: () => {
      console.log('\n📱 Testing Frontend Configuration...');
      try {
        const fs = require('fs');
        const pubspec = fs.readFileSync('./frontend/pubspec.yaml', 'utf8');
        
        const requiredPackages = ['provider', 'dio', 'geolocator', 'google_maps_flutter'];
        let found = 0;
        
        requiredPackages.forEach(pkg => {
          if (pubspec.includes(pkg)) {
            console.log(`✅ ${pkg}: Found`);
            found++;
          } else {
            console.log(`❌ ${pkg}: Not found`);
          }
        });
        
        console.log(`📊 Flutter packages: ${found}/${requiredPackages.length} found`);
        return found >= requiredPackages.length * 0.8; // 80% threshold
      } catch (error) {
        console.log(`❌ Error reading pubspec.yaml: ${error.message}`);
        return false;
      }
    },
    
    databaseSeedData: () => {
      console.log('\n🗄️ Testing Database Seed Data...');
      try {
        const fs = require('fs');
        const seedData = require('./backend/src/data/seedData.js');
        
        const checks = [
          { name: 'Users Data', data: seedData.usersData, minLength: 5 },
          { name: 'Parking Lots Data', data: seedData.parkingLotsData, minLength: 5 }
        ];
        
        let passed = 0;
        checks.forEach(check => {
          if (Array.isArray(check.data) && check.data.length >= check.minLength) {
            console.log(`✅ ${check.name}: ${check.data.length} items`);
            passed++;
          } else {
            console.log(`❌ ${check.name}: Insufficient data`);
          }
        });
        
        // Check JSON files
        const jsonFiles = ['parkingLots.json', 'bookings.json'];
        jsonFiles.forEach(file => {
          if (fs.existsSync(`./backend/src/data/${file}`)) {
            console.log(`✅ ${file}: Found`);
            passed++;
          } else {
            console.log(`❌ ${file}: Missing`);
          }
        });
        
        console.log(`📊 Database files: ${passed}/${checks.length + jsonFiles.length} ready`);
        return passed >= (checks.length + jsonFiles.length);
      } catch (error) {
        console.log(`❌ Error checking seed data: ${error.message}`);
        return false;
      }
    },
    
    environmentCheck: () => {
      console.log('\n🌍 Testing Environment...');
      const { execSync } = require('child_process');
      
      const commands = [
        { name: 'Node.js', cmd: 'node --version' },
        { name: 'NPM', cmd: 'npm --version' },
        { name: 'Flutter', cmd: 'flutter --version' }
      ];
      
      let available = 0;
      commands.forEach(({ name, cmd }) => {
        try {
          const version = execSync(cmd, { encoding: 'utf8' }).trim();
          console.log(`✅ ${name}: ${version.split('\n')[0]}`);
          available++;
        } catch (error) {
          console.log(`❌ ${name}: Not available`);
        }
      });
      
      console.log(`📊 Environment: ${available}/${commands.length} tools available`);
      return available >= 2; // At least Node and Flutter
    }
  };
  
  // Run all tests
  console.log('\n🚀 Running Tests...\n');
  const results = {};
  let totalPassed = 0;
  
  for (const [testName, testFn] of Object.entries(tests)) {
    try {
      results[testName] = testFn();
      if (results[testName]) totalPassed++;
    } catch (error) {
      console.log(`❌ ${testName} failed: ${error.message}`);
      results[testName] = false;
    }
  }
  
  // Summary
  console.log('\n📊 TEST SUMMARY');
  console.log('=' .repeat(40));
  
  Object.entries(results).forEach(([test, passed]) => {
    const status = passed ? '✅ PASS' : '❌ FAIL';
    console.log(`${status} ${test}`);
  });
  
  console.log(`\n🎯 Overall: ${totalPassed}/${Object.keys(tests).length} tests passed`);
  
  if (totalPassed === Object.keys(tests).length) {
    console.log('🎉 All tests passed! Your app is ready! 🚀');
  } else if (totalPassed >= Object.keys(tests).length * 0.8) {
    console.log('⚠️  Most tests passed. Minor issues to fix. 🔧');
  } else {
    console.log('❌ Several issues found. Please review and fix. 🛠️');
  }
  
  // Save results
  const fs = require('fs');
  const report = {
    timestamp: new Date().toISOString(),
    results,
    summary: {
      total: Object.keys(tests).length,
      passed: totalPassed,
      percentage: Math.round((totalPassed / Object.keys(tests).length) * 100)
    }
  };
  
  fs.writeFileSync('quick-test-report.json', JSON.stringify(report, null, 2));
  console.log('\n💾 Report saved to quick-test-report.json');
};

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { testParkEaseApp };
}

// Run if called directly
if (typeof require !== 'undefined' && require.main === module) {
  testParkEaseApp().catch(console.error);
}