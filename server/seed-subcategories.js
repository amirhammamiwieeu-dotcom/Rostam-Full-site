import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'

dotenv.config()

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SECRET_KEY,
  { auth: { autoRefreshToken: false, persistSession: false } }
)

// Structure: main_slug → [sub-categories]
const SUBCATEGORIES = {
  'home-kitchen': [
    { name: 'Furniture', slug: 'furniture', icon: 'fa-couch' },
    { name: 'Kitchen Appliances', slug: 'kitchen-appliances', icon: 'fa-blender' },
    { name: 'Home Decor', slug: 'home-decor', icon: 'fa-paint-brush' },
    { name: 'Bedding', slug: 'bedding', icon: 'fa-bed' },
  ],
  'beauty-health': [
    { name: 'Skincare', slug: 'skincare', icon: 'fa-spa' },
    { name: 'Makeup', slug: 'makeup', icon: 'fa-magic' },
    { name: 'Hair Care', slug: 'hair-care', icon: 'fa-cut' },
    { name: 'Fragrances', slug: 'fragrances', icon: 'fa-spray-can' },
  ],
  'books-stationery': [
    { name: 'Fiction', slug: 'fiction', icon: 'fa-book' },
    { name: 'Non-Fiction', slug: 'non-fiction', icon: 'fa-book-open' },
    { name: 'Textbooks', slug: 'textbooks', icon: 'fa-graduation-cap' },
    { name: 'Office Supplies', slug: 'office-supplies', icon: 'fa-pen' },
  ],
  'toys-kids': [
    { name: 'Action Figures', slug: 'action-figures', icon: 'fa-robot' },
    { name: 'Board Games', slug: 'board-games', icon: 'fa-chess' },
    { name: 'Educational Toys', slug: 'educational-toys', icon: 'fa-puzzle-piece' },
    { name: 'Baby Gear', slug: 'baby-gear', icon: 'fa-baby' },
  ],
  'sports-outdoors': [
    { name: 'Fitness Equipment', slug: 'fitness-equipment', icon: 'fa-dumbbell' },
    { name: 'Camping Gear', slug: 'camping-gear', icon: 'fa-campground' },
    { name: 'Cycling', slug: 'cycling', icon: 'fa-bicycle' },
    { name: 'Team Sports', slug: 'team-sports', icon: 'fa-basketball-ball' },
  ],
  'automotive': [
    { name: 'Car Parts', slug: 'car-parts', icon: 'fa-cog' },
    { name: 'Car Care', slug: 'car-care', icon: 'fa-car' },
    { name: 'Motorcycle Gear', slug: 'motorcycle-gear', icon: 'fa-motorcycle' },
    { name: 'Tools', slug: 'tools', icon: 'fa-tools' },
  ],
}

async function seedSubcategories() {
  console.log('🌱 Seeding subcategories...\n')

  // Fetch all main categories
  const { data: mainCategories, error: mainError } = await supabase
    .from('categories')
    .select('id, name, slug, parent_id')
    .is('parent_id', null)

  if (mainError) {
    console.error('❌ Failed to fetch main categories:', mainError.message)
    process.exit(1)
  }

  console.log('📁 Found main categories:')
  mainCategories.forEach((c) => console.log(`   - ${c.name} (${c.slug})`))
  console.log('')

  // Map: slug → id
  const catMap = {}
  mainCategories.forEach((c) => {
    catMap[c.slug] = c.id
  })

  let success = 0
  let skipped = 0
  let failed = 0

  for (const [mainSlug, subCats] of Object.entries(SUBCATEGORIES)) {
    const parentId = catMap[mainSlug]

    if (!parentId) {
      console.error(`❌ Main category not found: ${mainSlug}`)
      failed += subCats.length
      continue
    }

    console.log(`\n📂 Adding subcategories to "${mainSlug}":`)

    for (const sub of subCats) {
      // Check if already exists
      const { data: existing } = await supabase
        .from('categories')
        .select('id')
        .eq('slug', sub.slug)
        .maybeSingle()

      if (existing) {
        console.log(`   ⏭️  ${sub.name} (already exists)`)
        skipped++
        continue
      }

      // Insert
      const { error } = await supabase.from('categories').insert({
        name: sub.name,
        slug: sub.slug,
        icon: sub.icon,
        parent_id: parentId,
        sort_order: subCats.indexOf(sub) + 1,
        is_active: true,
        is_featured: false,
      })

      if (error) {
        console.error(`   ❌ ${sub.name}:`, error.message)
        failed++
      } else {
        console.log(`   ✅ ${sub.name}`)
        success++
      }
    }
  }

  console.log('\n' + '═'.repeat(50))
  console.log(`🎉 Done!`)
  console.log(`   ✅ Created:  ${success}`)
  console.log(`   ⏭️  Skipped:  ${skipped}`)
  console.log(`   ❌ Failed:   ${failed}`)
  console.log('═'.repeat(50))
}

seedSubcategories()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err)
    process.exit(1)
  })
