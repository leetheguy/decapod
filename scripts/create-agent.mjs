#!/usr/bin/env node

/**
 * create-agent.mjs
 * 
 * Interactive CLI tool to generate new agent instances from a template.
 * Prompts for agent name, copies template, and allows interactive skill selection.
 */

import inquirer from 'inquirer';
import yaml from 'js-yaml';
import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Paths
const PROJECT_ROOT = path.resolve(__dirname, '..');
const TEMPLATE_DIR = path.join(PROJECT_ROOT, 'extras', 'S3_structure', 'agents', 'template');
const AGENTS_DIR = path.join(PROJECT_ROOT, 'extras', 'S3_structure', 'agents');
const SKILLS_DIR = path.join(TEMPLATE_DIR, 'skills');

/**
 * Convert agent name to filesystem-safe slug
 * @param {string} name - Agent name
 * @returns {string} Slugified name
 */
function slugify(name) {
  return name
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '') // Remove special characters
    .replace(/[\s_-]+/g, '-')  // Replace spaces/underscores with hyphens
    .replace(/^-+|-+$/g, '');  // Remove leading/trailing hyphens
}

/**
 * Recursively copy template directory to new agent folder
 * @param {string} src - Source template directory
 * @param {string} dest - Destination agent directory
 */
function copyTemplate(src, dest) {
  try {
    fs.copySync(src, dest);
    console.log(`✓ Template copied to ${dest}`);
  } catch (error) {
    console.error(`Error copying template: ${error.message}`);
    throw error;
  }
}

/**
 * Read skills from the skills directory and extract skill information
 * @param {string} skillsDir - Path to skills directory
 * @returns {Array} Array of skill objects with name, description, location
 */
function parseSkillsFromDirectory(skillsDir) {
  try {
    if (!fs.existsSync(skillsDir)) {
      throw new Error(`Skills directory not found: ${skillsDir}`);
    }

    const files = fs.readdirSync(skillsDir);
    const skillFiles = files.filter(file => file.endsWith('.md'));
    
    if (skillFiles.length === 0) {
      throw new Error(`No skill files found in ${skillsDir}`);
    }

    const skills = [];
    
    for (const file of skillFiles) {
      const filePath = path.join(skillsDir, file);
      const fileContents = fs.readFileSync(filePath, 'utf8');
      
      // Parse YAML frontmatter
      const frontmatterMatch = fileContents.match(/^---\n([\s\S]*?)\n---/);
      if (!frontmatterMatch) {
        console.warn(`Warning: No frontmatter found in ${file}, skipping`);
        continue;
      }
      
      const frontmatter = yaml.load(frontmatterMatch[1]);
      if (!frontmatter || !frontmatter.name) {
        console.warn(`Warning: No name found in frontmatter of ${file}, skipping`);
        continue;
      }
      
      const skillName = frontmatter.name;
      const skillDescription = frontmatter.description || 'No description';
      const skillLocation = `/skills/${file}`;
      
      skills.push({
        name: skillName,
        description: skillDescription,
        location: skillLocation
      });
    }
    
    return skills;
  } catch (error) {
    console.error(`Error parsing skills from directory: ${error.message}`);
    throw error;
  }
}

/**
 * Interactive skill selection using inquirer checkbox
 * @param {Array} skills - Array of skill objects from YAML
 * @returns {Promise<Array>} Selected skill names
 */
async function selectSkills(skills) {
  // Build choices array for inquirer
  const choices = skills.map(skill => ({
    name: `${skill.name} - ${skill.description}`,
    value: skill.name,
    checked: true // All skills checked by default (they're in template)
  }));

  const { selectedSkills } = await inquirer.prompt([
    {
      type: 'checkbox',
      name: 'selectedSkills',
      message: 'Select skills for this agent (use arrow keys to navigate, space to toggle, enter to confirm):',
      choices,
      validate: (answer) => {
        // Basic validation - at least one skill must be selected
        if (answer.length === 0) {
          return 'You must select at least one skill';
        }
        return true;
      }
    }
  ]);

  return selectedSkills;
}

/**
 * Write filtered skills to YAML file
 * @param {string} yamlPath - Path to write skills YAML
 * @param {Array} allSkills - All skills from template
 * @param {Array} selectedSkillNames - Names of selected skills
 */
function writeSkillsYaml(yamlPath, allSkills, selectedSkillNames) {
  try {
    // Filter skills to only include selected ones
    const selectedSkills = allSkills.filter(skill => 
      selectedSkillNames.includes(skill.name)
    );

    const yamlData = {
      skills: selectedSkills
    };

    const yamlString = yaml.dump(yamlData, {
      indent: 2,
      lineWidth: -1, // No line wrapping
      quotingType: '"',
      forceQuotes: false
    });

    fs.writeFileSync(yamlPath, yamlString, 'utf8');
    console.log(`✓ Skills YAML written to ${yamlPath}`);
  } catch (error) {
    console.error(`Error writing skills YAML: ${error.message}`);
    throw error;
  }
}

/**
 * Main function
 */
async function main() {
  console.log('========================================');
  console.log('Decapod Agent Generator');
  console.log('========================================');
  console.log('');

  try {
    // Validate template directory exists
    if (!fs.existsSync(TEMPLATE_DIR)) {
      console.error(`Error: Template directory not found: ${TEMPLATE_DIR}`);
      process.exit(1);
    }

    if (!fs.existsSync(SKILLS_DIR)) {
      console.error(`Error: Skills directory not found: ${SKILLS_DIR}`);
      process.exit(1);
    }

    // Step 1: Prompt for agent name
    const { agentName } = await inquirer.prompt([
      {
        type: 'input',
        name: 'agentName',
        message: 'Enter agent name:',
        validate: (input) => {
          if (!input || input.trim().length === 0) {
            return 'Agent name cannot be empty';
          }
          return true;
        }
      }
    ]);

    const slug = slugify(agentName);
    const agentDir = path.join(AGENTS_DIR, slug);

    // Step 2: Check if directory already exists
    if (fs.existsSync(agentDir)) {
      const { overwrite } = await inquirer.prompt([
        {
          type: 'confirm',
          name: 'overwrite',
          message: `Agent directory already exists: ${agentDir}\nOverwrite?`,
          default: false
        }
      ]);

      if (!overwrite) {
        console.log('Operation cancelled.');
        process.exit(0);
      }

      // Remove existing directory
      fs.removeSync(agentDir);
      console.log(`✓ Removed existing directory: ${agentDir}`);
    }

    // Step 3: Copy template
    console.log(`\nCreating agent: ${slug}`);
    copyTemplate(TEMPLATE_DIR, agentDir);

    // Step 4: Parse template skills from skills directory
    const allSkills = parseSkillsFromDirectory(SKILLS_DIR);
    console.log(`✓ Found ${allSkills.length} skills in template`);

    // Step 5: Interactive skill selection
    console.log('');
    const selectedSkillNames = await selectSkills(allSkills);

    // Step 6: Generate new skills.yaml
    const newSkillsYamlPath = path.join(agentDir, 'definitions', '2_skills.yaml');
    writeSkillsYaml(newSkillsYamlPath, allSkills, selectedSkillNames);

    // Step 7: Summary output
    console.log('');
    console.log('========================================');
    console.log('Agent created successfully!');
    console.log('========================================');
    console.log(`Agent name: ${agentName}`);
    console.log(`Agent slug: ${slug}`);
    console.log(`Agent path: ${agentDir}`);
    console.log(`Selected skills (${selectedSkillNames.length}):`);
    selectedSkillNames.forEach(skillName => {
      const skill = allSkills.find(s => s.name === skillName);
      console.log(`  - ${skillName}: ${skill?.description || 'N/A'}`);
    });
    console.log('');

  } catch (error) {
    console.error(`\nError: ${error.message}`);
    if (error.stack) {
      console.error(error.stack);
    }
    process.exit(1);
  }
}

// Run main function
main();
